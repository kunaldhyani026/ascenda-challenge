require_relative 'abstract_supplier_hotel'
require_relative '../hotel_entities/amenity'
require_relative '../hotel_entities/location'
require_relative '../hotel_entities/image'
require_relative '../hotel_entities/image_collection'

module HotelsDataMerge
  module SupplierHotels
    class Paperflies < AbstractSupplierHotel
      include ApplicationHelper

      def get_id
        @hotel_data[:hotel_id]
      end

      def get_destination_id
        @hotel_data[:destination_id]
      end

      def get_name
        strip_or_empty(@hotel_data[:hotel_name])
      end

      def get_description
        strip_or_empty(@hotel_data[:details])
      end

      def get_booking_conditions
        booking_conditions = @hotel_data[:booking_conditions]
        booking_conditions.present? ? booking_conditions.map { |condition| condition.strip } : []
      end

      def get_amenities
        general_amenities = @hotel_data[:amenities][:general]
        room_amenities = @hotel_data[:amenities][:room]
        klass = HotelsDataMerge::HotelEntities::Amenity
        amenities = klass.new
        amenities.general = general_amenities.present? ? general_amenities.map{ |amenity| klass.format_amenity(amenity) } : []
        amenities.room = room_amenities.present? ? room_amenities.map{ |amenity| klass.format_amenity(amenity) } : []
        amenities
      end

      def get_images
        rooms_images = @hotel_data[:images][:rooms]
        site_images = @hotel_data[:images][:site]
        image_klass = HotelsDataMerge::HotelEntities::Image
        image_collection = HotelsDataMerge::HotelEntities::ImageCollection.new
        image_collection.rooms = rooms_images.present? ? rooms_images.map { |image| image_klass.new(image[:link], image[:caption]) } : []
        image_collection.site = site_images.present? ? site_images.map { |image| image_klass.new(image[:link], image[:caption]) } : []
        image_collection
      end

      def get_location
        location = HotelsDataMerge::HotelEntities::Location.new
        location.address = strip_or_empty(@hotel_data[:location][:address])
        location.country = strip_or_empty(@hotel_data[:location][:country])
        location
      end
    end
  end
end


