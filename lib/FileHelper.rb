class FileHelper
    attr_accessor :layer, :level

    def initialize(layer, level)
        raise "Invalid layer name" if !FileHelper::SUBFOLDERS_LAYERS.has_key?(layer)
        @layer = layer
        @level = level
        `mkdir -p #{FileHelper::FOLDER}/`
        prepare_folders
    end

    def prepare_folders
        `mkdir -p #{tiles_path}`
    end

    def tiles_path
        "#{FileHelper::FOLDER}/#{@layer}/tiles/x#{@level}"
    end

    def tile_path_file(row_i, col_i)
        "#{tiles_path}/tile_#{col_i}_#{row_i}.jpg"
    end

    def technical_layer_name
        FileHelper::SUBFOLDERS_LAYERS[@layer]
    end

    FOLDER="dist"

    SUBFOLDERS_LAYERS = {
        "ign_card" => "GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD",
        "ign_card_zoom" => "GEOGRAPHICALGRIDSYSTEMS.MAPS"
    }
end