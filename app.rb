require_relative 'lib/tilezone'
require 'net/http'

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
layer = "ign_card_zoom"

zone = TileZone.new(
    Tile.new(top_left_lng, top_left_lat, level),
    Tile.new(bottom_right_lng, bottom_right_lat, level)
)

# preparing folders
file_helper = FileHelper.new(layer, level)

tiles_path_ordered = []

start_exec = Time.now
zone.download(file_helper) do |path, count, progress|
    print "Downloading tiles : #{progress}% (#{count.to_i}/#{zone.size}) #{count != zone.size ? "\r" : "\n"}"
    tiles_path_ordered.push(path)
end

# Montage
`magick montage #{tiles_path_ordered.join(" ")} -geometry 256x256 -tile #{zone.width}x#{zone.height} #{output_file} --output #{output_file}`

p "Exec time : " + ((Time.now - start_exec) * 1000).to_s + "ms"