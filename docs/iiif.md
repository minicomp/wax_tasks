# wax:iiif

## What it does
`wax:iiif` takes a local directory of images and generates tiles and data that work with a IIIF compliant image viewer like [OpenSeaDragon](https://openseadragon.github.io/).

## Requirements

To use the IIIF task, you will also need to have ImageMagick installed and functional. You can check to see if you have ImageMagick by running:
```bash
$ convert -version
  Version: ImageMagick 6.9.9-20 Q16 x86_64 2017-10-15 http://www.imagemagick.org
  Copyright: © 1999-2017 ImageMagick Studio LLC
  License: http://www.imagemagick.org/script/license.php
  Features: Cipher DPC Modules
  Delegates (built-in): bzlib freetype jng jpeg ltdl lzma png tiff xml zlib
```

*Note: `wax:iiif` does not create layouts or implement viewers to use with the tiles and json generated; you will need to make your own or use `wax_theme`, which comes with a `iiif_image` include.*



## Configuration

You will need to make a directory `iiif` in the the `_data` folder of your Jekyll site.  Next, you will need to make a folder for each iiif collection inside that, and put your collection's full size source images inside.

For example:

```
.
└── _data
    └── iiif
        ├── collection_1
        |   ├── c1-item1.jpg
        |   └── c1-item2.jpg
        └── collection_2
            ├── c2-item1.jpg
            └── c2-item2.jpg
```

This will generate a directory `iiif` in the root of your site that includes all the tiles and iiif json:

```
.
└── iiif
    ├── collection  # collection level data
    |   └── top.json
    ├── images      # image api (i.e. canvas) level data
    |   └── c1-item1-1
    |   |   └── 0,0,512,512
    |   |   └── ...
    |   |   └── info.json
    |   └── ...
    ├── c1-item1-1  # presentation api (i.e. manifest) level data
    |   └── manifest.json
    └── ...
```

*Note that the Image API info in `tiles/images/` will have a `-1` appended to the end of each item directory. This is where the Presentation API info is, which is an artifact of the `iiif_s3` gem.*



## To use
`$ bundle exec rake wax:iiif collection-name`
