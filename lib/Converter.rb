module Converter
    def self.coord_to_tile(lng, lat, level)
        lng, lat, _ = `echo #{lng} #{lat} | cs2cs +init=epsg:4326 +to +init=epsg:3857`.split.map(&:to_f)
    
        # Fixed values from https://wxs.ign.fr/essentiels/geoportail/wmts?SERVICE=WMTS&REQUEST=GetCapabilities
        # TileMatrixSet of PM, EPSG:3857
        top_left_x = -20037508
        top_left_y = 20037508
    
        tile_col = ((lng - top_left_x) / Converter.meter_per_pixel(level)).to_i
        tile_row = ((top_left_y - lat) / Converter.meter_per_pixel(level)).to_i
    
        [tile_row, tile_col]
    end

    def self.meter_per_pixel(level)
        # 256 is the size in pixel of a tile
        256.0 * RESOLUTIONS_OF_LEVELS[level]
    end

    # From https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-tuilees-wmts-ogc#1592
    # Index of array represents the equivalent level
    RESOLUTIONS_OF_LEVELS = [
        156543.0339280410,
        78271.5169640205,
        39135.7584820102,
        19567.8792410051,
        9783.9396205026,
        4891.9698102513,
        2445.9849051256,
        1222.9924525628,
        611.4962262814,
        305.7481131407,
        152.8740565704,
        76.4370282852,
        38.2185141426,
        19.1092570713,
        9.5546285356,
        4.7773142678,
        2.3886571339,
        1.1943285670,
        0.5971642835,
        0.2985821417,
        0.1492910709,
        0.0746455354
    ]
end