require_relative 'hotel_entities/location'
require_relative 'hotel_entities/amenity'
require_relative 'hotel_entities/image_collection'

module HotelsDataMerge
  class MergeHelper
    extend ApplicationHelper

    # selecting the longest name
    def self.select_name(saved_hotel, supplier_hotel)
      saved_hotel.name.length > supplier_hotel.get_name.length ? saved_hotel.name.presence : supplier_hotel.get_name.presence
    end

    # Merging locations of saved_hotel and supplier_hotel object.
    # For city, address, latitude, longitude - the first not null and non-empty value is picked.
    # For country - Priority to picking Country Code (char length - 2, ex: 'SG') if possible else non-null country
    def self.merge_locations(saved_hotel, supplier_hotel)
      location = HotelEntities::Location.new
      supplier_hotel_location = supplier_hotel.get_location

      location.address = saved_hotel.location.address.presence || supplier_hotel_location.address.presence
      location.city = saved_hotel.location.city.presence || supplier_hotel_location.city.presence
      location.latitude = saved_hotel.location.latitude.presence || supplier_hotel_location.latitude.presence
      location.longitude = saved_hotel.location.longitude.presence || supplier_hotel_location.longitude.presence
      location.country = saved_hotel.location.country.present? && supplier_hotel_location.country.present? ? select_string_of_specified_length(saved_hotel.location.country, supplier_hotel_location.country, 2) : saved_hotel.location.country.presence || supplier_hotel_location.country.presence
      location
    end

    # Merging descriptions of saved_hotel and supplier_hotel object
    # if configured to merged_description True, merges both the description
    # else select the longest description
    def self.merge_descriptions(saved_hotel, supplier_hotel)
      return "#{saved_hotel.description} #{supplier_hotel.get_description}".presence if Rails.application.config.merge_description

      saved_hotel.description.length > supplier_hotel.get_description.length ? saved_hotel.description.presence : supplier_hotel.get_description.presence
    end

    # Merging amenities of saved_hotel and supplier_hotel object
    # We have entries like 'BusinessCenter' and 'business center', to handle this - all spaces are removed from each amenity
    # Then Both general and room amenities are merged to keep only unique elements in the array.
    # Also we have seen that some suppliers only provide general amenities, some providing only room amenities too and some provide both general and room amenities
    # If there are overlapping amenities both in general and room then -> general amenity is given prefernence so keeping only those amenities in room which are not in general
    def self.merge_amenities(saved_hotel, supplier_hotel)
      amenities = HotelEntities::Amenity.new
      amenities.general = (clean_array(saved_hotel.amenities.general) + clean_array(supplier_hotel.get_amenities.general)).uniq
      amenities.room = (clean_array(saved_hotel.amenities.room) + clean_array(supplier_hotel.get_amenities.room)).uniq
      amenities.room -= amenities.general
      amenities
    end

    # Merging images of saved_hotel and supplier_hotel object
    # Merging images for all the categories (site, amenities, rooms) and ensuring that only unique images as per url remains in each category post merging
    def self.merge_images(saved_hotel, supplier_hotel)
      image_collection = HotelEntities::ImageCollection.new
      image_keys = saved_hotel.images.keys
      image_keys.each do |image_key|
        unique_images = (saved_hotel.images[image_key] + supplier_hotel.get_images[image_key]).uniq(&:link)
        image_collection[image_key] = unique_images
      end
      image_collection
    end

    # Merging booking conditions of saved_hotel and supplier_hotel object
    # Resulting booking conditions is an array with only unique booking conditions
    def self.merge_booking_conditions(saved_hotel, supplier_hotel)
      (saved_hotel.booking_conditions + supplier_hotel.get_booking_conditions).uniq
    end

    def self.select_string_of_specified_length(str1, str2, expected_length)
      return str1.upcase if str1.length == expected_length
      return str2.upcase if str2.length == expected_length

      str1
    end
  end
end
