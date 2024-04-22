module HotelsDataMerge
  module HotelEntities
    class ImageCollection
      attr_accessor :amenities, :rooms, :site

      def initialize
        @amenities = []
        @rooms = []
        @site = []
      end

      def [](key)
        send(key)
      end

      def []=(key, value)
        send("#{key}=", value)
      end

      def keys
        instance_variables.map { |var| var.to_s.delete('@') }
      end
    end
  end
end

