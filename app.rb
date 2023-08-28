require_relative 'lib/converter'
require_relative 'lib/filehelper'
require_relative 'lib/tilezone'

# ARGS
recognized_args = %w(-o -top-left -bottom-right -level)
args = ARGV.map { |arg| arg.split("=") }.to_h.reject { |k, v| !recognized_args.include?(k) }

output_file = args.has_key?("-o") ? args["-o"] : "./dist/map.jpg"
level = args.has_key?("-level") ? args["-level"].to_i : 16
raise "Zoom is out of valid range (max 21)" if level < 0 && level > 21

top_left = args["-top-left"]
bottom_right = args["-bottom-right"]

raise 'No coord provided' if !top_left || !bottom_right

top_left_lng, top_left_lat = top_left.split(',').map(&:to_f)
bottom_right_lng, bottom_right_lat = bottom_right.split(',').map(&:to_f)

# SETUP
layer = "GEOGRAPHICALGRIDSYSTEMS.MAPS"

zone = TileZone.new(
    Tile.new(top_left_lng, top_left_lat, level),
    Tile.new(bottom_right_lng, bottom_right_lat, level)
)

# preparing folders
file_helper = FileHelper.new(layer, level)

# Found when inspected element on ign geoportail
key = "an7nvfzojv5wa96dsga5nk8w"

tiles_path_ordered = []

start_exec = Time.now
zone.each do |row_i, col_i|
    tile_params = "TileMatrix=#{level}&TileCol=#{col_i}&TileRow=#{row_i}"
    path = "#{file_helper.tiles_path}/tile_#{col_i}_#{row_i}.jpg"

    unless File.exists?(path)
        req = "wget -O #{path} --header='Host: wxs.ign.fr' --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0' 'https://wxs.ign.fr/#{key}/geoportail/wmts?layer=#{layer}&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image/jpeg&#{tile_params}'"
        `#{req}`
    end

    tiles_path_ordered.push("#{file_helper.tiles_path}/tile_#{col_i}_#{row_i}.jpg")
end

# Montage
`magick montage #{tiles_path_ordered.join(" ")} -geometry 256x256 -tile #{zone.width}x#{zone.height} #{output_file} --output #{output_file}`

p "Exec time : " + ((Time.now - start_exec) * 1000).to_s + "ms"