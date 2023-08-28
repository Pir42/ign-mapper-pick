class FileHelper
    attr_accessor :layer, :level

    def initialize(layer, level)
        raise "Invalid layer name" if !FileHelper::SUBFOLDERS_LAYERS.has_key?(layer)
        @layer = FileHelper::SUBFOLDERS_LAYERS[layer]
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

    FOLDER="dist"

    SUBFOLDERS_LAYERS = {
        "GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD" => "ign_card",
        "GEOGRAPHICALGRIDSYSTEMS.MAPS" => "ign_card_zoom"
    }
end