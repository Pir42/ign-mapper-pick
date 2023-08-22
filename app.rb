require_relative 'lib/converter'

recognized_args = %w(-o -top-left -bottom-right -zoom)
args = ARGV.map { |arg| arg.split("=") }.to_h.reject { |k, v| !recognized_args.include?(k) }

output_file = args.has_key?("-o") ? args["-o"] : "./dist/map.jpg"
zoom = args.has_key?("-zoom") ? args["-zoom"].to_i : 16
raise "Zoom is out of valid range (max 21)" if zoom < 0 && zoom > 21

top_left = args["-top-left"]
bottom_right = args["-bottom-right"]

raise 'No coord provided' if !top_left || !bottom_right

top_left_lng, top_left_lat = top_left.split(',').map(&:to_f)
bottom_right_lng, bottom_right_lat = bottom_right.split(',').map(&:to_f)

# define name of folders for layers for better comprehension
subfolders_layers = {
    "GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD" => "ign_card",
    "GEOGRAPHICALGRIDSYSTEMS.MAPS" => "ign_card_zoom"
}

layer = "GEOGRAPHICALGRIDSYSTEMS.MAPS"

width_tile = 256
height_tile = 256

start_tile_row, start_tile_col = Converter.coord_to_tile(top_left_lng, top_left_lat, zoom)
end_tile_row, end_tile_col = Converter.coord_to_tile(bottom_right_lng, bottom_right_lat, zoom)

col_length = end_tile_col - start_tile_col
row_length = end_tile_row - start_tile_row

# preparing canvas
full_width = row_length*width_tile
full_height = col_length*height_tile

# preparing folders
subfolder_layer = subfolders_layers.has_key?(layer) ? subfolders_layers[layer] : layer
tiles_folder = "dist/#{subfolder_layer}/tiles"
scale_tiles_folder = "#{tiles_folder}/x#{zoom}"

`mkdir -p dist/`
`mkdir -p #{tiles_folder}`
`mkdir -p #{scale_tiles_folder}`

# Found when inspected element on ign geoportail
key = "an7nvfzojv5wa96dsga5nk8w"

tiles_path_ordered = []

start_exec = Time.now
row_length.times do |row_i|
    col_length.times do |col_i|
        tile_params = "TileMatrix=#{zoom}&TileCol=#{start_tile_col+col_i}&TileRow=#{start_tile_row+row_i}"
        path = "#{scale_tiles_folder}/tile_#{start_tile_col+col_i}_#{start_tile_row+row_i}.jpg"

        unless File.exists?(path)
            req = "wget -O #{path} --header='Host: wxs.ign.fr' --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0' 'https://wxs.ign.fr/#{key}/geoportail/wmts?layer=#{layer}&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image/jpeg&#{tile_params}'"
            `#{req}`
        end

        tiles_path_ordered.push("#{scale_tiles_folder}/tile_#{start_tile_col+col_i}_#{start_tile_row+row_i}.jpg")
    end
end

# Montage
`magick montage #{tiles_path_ordered.join(" ")} -geometry 256x256 -tile #{col_length}x#{row_length} #{output_file} --output #{output_file}`

p "Exec time : " + ((Time.now - start_exec) * 1000).to_s + "ms"