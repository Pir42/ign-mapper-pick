require_relative 'tile'

class TileZone
    attr_accessor :top_left_tile, :bottom_right_tile

    def initialize(top_left_tile, bottom_right_tile)
        @top_left_tile = top_left_tile
        @bottom_right_tile = bottom_right_tile
    end

    def width
        @bottom_right_tile.col - @top_left_tile.col
    end

    def height
        @bottom_right_tile.row - @top_left_tile.row
    end

    def size
        width * height
    end

    def each
        width.times do |row_i|
            height.times do |col_i|
                yield(@top_left_tile.row+row_i, @top_left_tile.col+col_i)
            end
        end
    end
end