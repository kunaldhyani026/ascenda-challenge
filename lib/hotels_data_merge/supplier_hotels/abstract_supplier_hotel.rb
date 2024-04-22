module HotelsDataMerge
  module SupplierHotels
    class AbstractSupplierHotel
      def initialize(hotel_data)
        @hotel_data = hotel_data
      end

      def get_id
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def get_destination_id
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def get_name
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def get_description
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def get_booking_conditions
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def get_amenities
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def get_images
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def get_location
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
