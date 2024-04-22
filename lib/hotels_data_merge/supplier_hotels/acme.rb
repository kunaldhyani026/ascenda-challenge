require_relative 'abstract_supplier_hotel'
require_relative '../hotel_entities/amenity'
require_relative '../hotel_entities/location'

module HotelsDataMerge
  module SupplierHotels
    class Acme < AbstractSupplierHotel
      include ApplicationHelper

      def get_id
        @hotel_data[:Id]
      end

      def get_destination_id
        @hotel_data[:DestinationId]
      end

      def get_name
        strip_or_empty(@hotel_data[:Name])
      end

      def get_description
        strip_or_empty(@hotel_data[:Description])
      end

      def get_booking_conditions
        []
      end

      def get_amenities
        general_amenities = @hotel_data[:Facilities]
        klass = HotelsDataMerge::HotelEntities::Amenity
        amenities = klass.new
        amenities.general = general_amenities.present? ? general_amenities.map{ |amenity| klass.format_amenity(amenity) } : []
        amenities
      end

      def get_images
        HotelsDataMerge::HotelEntities::ImageCollection.new
      end

      def get_location
        location = HotelsDataMerge::HotelEntities::Location.new
        # address for acme supplier is address concatenated with the postal code
        location.address = "#{strip_or_empty(@hotel_data[:Address])} #{strip_or_empty(@hotel_data[:PostalCode])}"
        location.city = strip_or_empty(@hotel_data[:City])
        location.country = strip_or_empty(@hotel_data[:Country])
        location.latitude = @hotel_data[:Latitude]
        location.longitude = @hotel_data[:Longitude]
        location
      end
    end
  end
end

