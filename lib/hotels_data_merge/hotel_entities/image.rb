module HotelsDataMerge
  module HotelEntities
    class Image
      attr_reader :link, :description

      def initialize(link, description)
        @link = link
        @description = description
      end
    end
  end
end

