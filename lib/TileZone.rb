require_relative 'tile'
require_relative 'IGNServices'

class TileZone
    attr_accessor :top_left_tile, :bottom_right_tile
    include IGNServices

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

    def download(file_helper)
        count = 0.0
        each do |row_i, col_i|
            path = file_helper.tile_path_file(row_i, col_i)

            unless File.exists?(path)
                request_tile(row_i, col_i, file_helper.level, file_helper.technical_layer_name, path)
            end

            count += 1.0
            yield(path, count, '%.2f' % (count.to_f/size.to_f*100))
        end
    end
end