require 'nokogiri'
require 'net/http'
require_relative 'lib/converter'

recognized_args = %w(-o)
args = ARGV.map { |arg| arg.split("=") }.to_h.reject { |k, v| !recognized_args.include?(k) }

output_file = args.has_key?("-o") ? args["-o"] : "./dist/map.jpg"

key = "an7nvfzojv5wa96dsga5nk8w"

# define name of folders for layers for better comprehension
subfolders_layers = {
    "GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD" => "ign_card",
    "ELEVATION.SLOPES" => "elevation",
    "GEOGRAPHICALGRIDSYSTEMS.MAPS" => "ign_card_zoom"
}

layer = "GEOGRAPHICALGRIDSYSTEMS.MAPS.SCAN-EXPRESS.STANDARD"

# 
tile_matrix = 16
width_tile = 512
height_tile = 512

start_tile_row, start_tile_col = Converter.coord_to_tile(-1.1591903279164262, 45.08915008830281, tile_matrix)
end_tile_row, end_tile_col = Converter.coord_to_tile(-1.1003434500368225, 45.02705215830905, tile_matrix)

col_length = end_tile_col - start_tile_col
row_length = end_tile_row - start_tile_row

# preparing canvas
full_width = row_length*width_tile
full_height = col_length*height_tile

# preparing folders
subfolder_layer = subfolders_layers.has_key?(layer) ? subfolders_layers[layer] : layer
tiles_folder = "dist/#{subfolder_layer}/tiles"
scale_tiles_folder = "#{tiles_folder}/x#{tile_matrix}"

`mkdir -p dist/`
`mkdir -p #{tiles_folder}`
`mkdir -p #{scale_tiles_folder}`

# creating white canvas of size of future map
`convert -size #{full_height}x#{full_width} canvas:white -colorspace sRGB -type truecolor --output #{output_file}`

row_length.times do |row_i|
    col_length.times do |col_i|
        tile_params = "TileMatrix=#{tile_matrix}&TileCol=#{start_tile_col+col_i}&TileRow=#{start_tile_row+row_i}"
        path = "#{scale_tiles_folder}/tile_#{start_tile_col+col_i}_#{start_tile_row+row_i}.jpg"

        unless File.exists?(path)
            req = "wget -O #{path} --header='Host: wxs.ign.fr' --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0' 'https://wxs.ign.fr/#{key}/geoportail/wmts?layer=#{layer}&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image/jpeg&#{tile_params}'"
            `#{req}`
        end

        `magick composite -geometry +#{height_tile*col_i}+#{width_tile*row_i} #{path} #{output_file} --output #{output_file}`
    end
end
