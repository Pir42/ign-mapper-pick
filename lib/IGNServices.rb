module IGNServices
    def request_tile(row_i, col_i, level, layer, output_path)
        `wget -O #{output_path} -q --header='Host: wxs.ign.fr' --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:88.0) Gecko/20100101 Firefox/88.0' 'https://wxs.ign.fr/#{KEY}/geoportail/wmts?layer=#{layer}&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image/jpeg&#{tile_params(row_i, col_i, level)}'`
    end

    def tile_params(row_i, col_i, level)
        "TileMatrix=#{level}&TileCol=#{col_i}&TileRow=#{row_i}"
    end

    KEY="an7nvfzojv5wa96dsga5nk8w"
end