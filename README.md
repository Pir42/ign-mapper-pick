# IGN Mapper Pick

Create high-res pictures of map provided by IGN by downloading tiles at given coordinates

## Setup

You will need [ImageMagick](https://imagemagick.org/script/download.php), [PROJ](https://proj.org/en/9.2/install.html#install) and `wget`.

## Usage

```bash
ruby app.rb -top-left=2.2055824806882596,48.87745817562872 -bottom-right=2.2159992666936335,48.86847726150275 -zoom=18 -o=./
```

Arguments :
- o : path for the output map file (jpeg). If none, will be dist/map.jpg
- zoom : zoom level between 0 and 21. If none, default is 16.
- top-left : lng and lat for the top left point of the zone you want to capture
- bottom-right : lng and lat for the bottom right point of the zone you want to capture

*The top and bottom point will represent the rectangle zone captured*

## Good to know

As a map is assembled of lot of tiles, it will take space on your hardrive. The downloaded tiles can be reused by the script. Once you're done working capturing an area you can delete everything under `dist/`.