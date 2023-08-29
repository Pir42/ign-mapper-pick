require_relative 'Converter'
require_relative 'FileHelper'

class Tile
    attr_accessor :width, :height, :col, :row, :lng, :lat, :level

    #
    # @param lng [Float]
    # @param lat [Float]
    # @param level [Integer] between 1 and 21
    #
    def initialize(lng, lat, level)
        @lng = lng
        @lat = lat
        @level = level
        @width = Tile::DEFAULT_WIDTH
        @height = Tile::DEFAULT_HEIGHT
        @row, @col = Converter.coord_to_tile(@lng, @lat, @level)
    end

    DEFAULT_WIDTH=256
    DEFAULT_HEIGHT=256
end