module HotelsDataMerge
  module HotelEntities
    class Amenity
      attr_accessor :general, :room

      def initialize
        @general = []
        @room = []
      end

      def self.format_amenity(amenity)
        amenity.to_s.strip.downcase
      end
    end
  end
end
