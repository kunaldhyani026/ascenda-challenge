# This class is used for gathering, cleaning and storing hotel data from suppliers.
require_relative 'supplier_hotels/acme'
require_relative 'supplier_hotels/patagonia'
require_relative 'supplier_hotels/paperflies'
require_relative 'hotel'
require_relative 'merge_helper'

module HotelsDataMerge
  class SupplierDataLoader
    SUPPLIER_FACTORY = [
      {
        id: 1,
        url_endpoint: 'acme',
        factory: SupplierHotels::Acme
      },
      {
        id: 2,
        url_endpoint: 'patagonia',
        factory: SupplierHotels::Patagonia
      },
      {
        id: 3,
        url_endpoint: 'paperflies',
        factory: SupplierHotels::Paperflies
      }
    ].freeze

    def initialize
      @suppliers = {}
      @hotel_ids = Set.new
    end

    # Loads hotels data from the each supplier and process it to create Supplier Hotel class objects
    # Then merges the hotel data to prepare complete dataset and store it in cache.
    def procure_data
      SUPPLIER_FACTORY.each do |supplier|
        response = SupplierApiClient.get_data(supplier[:url_endpoint])
        return response if response.is_a?(Hash) && response.has_key?(:error_body)

        process_response(response, supplier)
      end
      process_and_write_to_cache
      { success_body: { code: 200, message: 'ok' } }
    end

    private

    # Processes all the hotels using hotel_ids received by all the suppliers
    # merges hotels and saves them to cache
    def process_and_write_to_cache
      Rails.cache.write('hotels', {}) # Creating empty hotels cache
      @hotel_ids.each { |hotel_id| save_hotel(hotel_id) } # This method is merging hotels and writing to cache.
      saved_hotels = Rails.cache.read('hotels') # Read the final cached_hotels
      Rails.cache.write('hotels', saved_hotels, expires_in: 24.hours) # Setting cache data expiry time to 24 hours
    end

    # Process response which is an array of hashes, each hash containing the hotel info
    # Creates hotel objects using corresponding supplier factory which implements abstract_supplier_hotel interface
    # Keep tracks of all the unique hotel ids and maintains map of supplier_id to list of hotel objects provided by that supplier
    def process_response(response, supplier)
      @suppliers[supplier[:id]] = []
      response.each do |hotel_data|
        hotel_object = supplier[:factory].new(hotel_data.with_indifferent_access)
        @hotel_ids.add(hotel_object.get_id)
        @suppliers[supplier[:id]] << hotel_object
      end
    end

    # Tries to get saved_hotel from cache using hotel_id (this can give nil too)
    # Traverses all the supplier hotels one by one
    # Finds the matching supplier hotel from current supplier using hotel_id
    # If matching supplier hotel found, creates the hotel (by merging of saved_hotel too if exists) and save it to cache
    def save_hotel(hotel_id)
      @suppliers.each do |_supplier_id, supplier_hotels|
        saved_hotels = Rails.cache.read('hotels')
        saved_hotel = saved_hotels[hotel_id]
        matched_supplier_hotel = supplier_hotels.find{ |hotel| hotel.get_id == hotel_id }
        if matched_supplier_hotel
          merged_hotel = merge_hotels(saved_hotel, matched_supplier_hotel, hotel_id)
          saved_hotels[hotel_id] = merged_hotel
          Rails.cache.write('hotels', saved_hotels)
        end
      end
    end

    # Creates new hotel object by using saved_hotel and supplier_hotel object
    # If saved_hotel exists, merges both the hotels as per merging rules
    # If doesn't exists, creates new hotel as per supplier_hotel object only
    def merge_hotels(saved_hotel, supplier_hotel, hotel_id)
      hotel = Hotel.new
      hotel.id = hotel_id
      hotel.destination_id = supplier_hotel.get_destination_id

      if saved_hotel
        hotel.name = MergeHelper.select_name(saved_hotel, supplier_hotel)
        hotel.location = MergeHelper.merge_locations(saved_hotel, supplier_hotel)
        hotel.description = MergeHelper.merge_descriptions(saved_hotel, supplier_hotel)
        hotel.amenities = MergeHelper.merge_amenities(saved_hotel, supplier_hotel)
        hotel.images = MergeHelper.merge_images(saved_hotel, supplier_hotel)
        hotel.booking_conditions = MergeHelper.merge_booking_conditions(saved_hotel, supplier_hotel)
      else
        hotel.name = supplier_hotel.get_name
        hotel.location = supplier_hotel.get_location
        hotel.description = supplier_hotel.get_description
        hotel.amenities = supplier_hotel.get_amenities
        hotel.images = supplier_hotel.get_images
        hotel.booking_conditions = supplier_hotel.get_booking_conditions
      end
      hotel
    end
  end
end
