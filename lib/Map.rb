require_relative 'tile'
require_relative 'IGNServices'

class Map
    attr_accessor :layer, :level, :top_left_tile, :bottom_right_tile
    include IGNServices

    #
    # @param layer [String]
    # @param level [Integer] between 1 and 21
    # @param top_left [Array<Float, Float>]
    # @param bottom_right [Array<Float, Float>]
    #
    def initialize(layer, level, top_left, bottom_right)
      @layer = layer
      @level = level
      @top_left_tile = Tile.new(top_left[0], top_left[1], @level)
      @bottom_right_tile = Tile.new(bottom_right[0], bottom_right[1], @level)

      prepare_folders
    end

    def prepare_folders
        `mkdir -p #{tiles_path}`
    end

    def tiles_path
        "#{Map::WORKING_DIR}/#{@layer}/tiles/x#{@level}"
    end

    def tile_path_file(row_i, col_i)
        "#{tiles_path}/tile_#{col_i}_#{row_i}.jpg"
    end

    def technical_layer_name
        Map::SUBFOLDERS[@layer]
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

    def download_tiles
        count = 0.0
        each do |row_i, col_i|
            path = tile_path_file(row_i, col_i)
            request_tile(row_i, col_i, @level, technical_layer_name, path) unless File.exists?(path)
            count += 1.0
            yield(path, count, '%.2f' % (count.to_f/size.to_f*100))
        end
    end

    #
    # @return paths [Array<String>]
    #
    def ordered_tiles_paths
        paths = []
        each do |row_i, col_i|
            paths.push(tile_path_file(row_i, col_i))
        end
        paths
    end

    def assemble(output_file)
        `magick montage #{ordered_tiles_paths.join(" ")} -geometry 256x256 -tile #{height}x#{width} #{output_file}`
    end

    WORKING_DIR="dist"

    LAYERS=%w(ign_card ign_card_zoom)

    SUBFOLDERS = {
        "ign_card" => "GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD",
        "ign_card_zoom" => "GEOGRAPHICALGRIDSYSTEMS.MAPS"
    }
end