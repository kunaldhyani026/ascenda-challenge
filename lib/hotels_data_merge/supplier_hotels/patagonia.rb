require_relative 'abstract_supplier_hotel'
require_relative '../hotel_entities/amenity'
require_relative '../hotel_entities/location'
require_relative '../hotel_entities/image'
require_relative '../hotel_entities/image_collection'

module HotelsDataMerge
  module SupplierHotels
    class Patagonia < AbstractSupplierHotel
      include ApplicationHelper
      def get_id
        @hotel_data[:id]
      end

      def get_destination_id
        @hotel_data[:destination]
      end

      def get_name
        strip_or_empty(@hotel_data[:name])
      end

      def get_description
        strip_or_empty(@hotel_data[:info])
      end

      def get_booking_conditions
        []
      end

      def get_amenities
        room_amenities = @hotel_data[:amenities]
        klass = HotelsDataMerge::HotelEntities::Amenity
        amenities = klass.new
        amenities.room = room_amenities.present? ? room_amenities.map{ |amenity| klass.format_amenity(amenity) } : []
        amenities
      end

      def get_images
        amenities_images = @hotel_data[:images][:amenities]
        rooms_images = @hotel_data[:images][:rooms]
        image_klass = HotelsDataMerge::HotelEntities::Image
        image_collection = HotelsDataMerge::HotelEntities::ImageCollection.new
        image_collection.amenities = amenities_images.present? ? amenities_images.map { |image| image_klass.new(image[:url], image[:description]) } : []
        image_collection.rooms = rooms_images.present? ? rooms_images.map { |image| image_klass.new(image[:url], image[:description]) } : []
        image_collection
      end

      def get_location
        location = HotelsDataMerge::HotelEntities::Location.new
        location.address = strip_or_empty(@hotel_data[:address])
        location.latitude = @hotel_data[:lat]
        location.longitude = @hotel_data[:lng]
        location
      end
    end
  end
end



