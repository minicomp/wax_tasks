# wax_tasks 🐝
[![Gem Version](https://badge.fury.io/rb/wax_tasks.svg)](https://badge.fury.io/rb/wax_tasks) ![License](https://img.shields.io/badge/license-MIT-yellowgreen.svg) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![docs](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](https://www.rubydoc.info/github/mnyrop/wax_tasks/)

[![Build Status](https://travis-ci.org/mnyrop/wax_tasks.svg?branch=rubocop)](https://travis-ci.org/mnyrop/wax_tasks) [![](https://img.shields.io/librariesio/github/mnyrop/wax_tasks.svg)](https://libraries.io/github/mnyrop/wax_tasks) [![Maintainability](https://api.codeclimate.com/v1/badges/5974d49e115dadf9f8df/maintainability)](https://codeclimate.com/github/mnyrop/wax_tasks/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/5974d49e115dadf9f8df/test_coverage)](https://codeclimate.com/github/mnyrop/wax_tasks/test_coverage)

__wax_tasks__ is gem-packaged set of [Rake](https://ruby.github.io/rake/) tasks for creating minimal exhibition sites with [Jekyll](https://jekyllrb.com/).

It can be used to:
- generate collection markdown pages from a metadata file ([wax:pagemaster](#waxpagemaster))
- generate a client-side search index ([wax:lunr](#waxlunr))
- generate either IIIF-compliant derivatives ([wax:derivatives:iiif](#waxderivativesiiif)) or simple image derivatives ([wax:derivatives:simple](#waxderivativessimple)) from local image and pdf files

.. and more.

<br>
<img src="https://raw.githubusercontent.com/minicomp/wiki/master/assets/wax_screen.gif"/>


# Getting Started

## Prerequisites

You'll need `Ruby >= 2.4` with `bundler` installed. Check your versions with:
```bash
$ ruby -v
  ruby 2.4.2p198 (2017-09-14 revision 59899) [x86_64-darwin15]

$ bundler -v
  Bundler version 1.16.1
```

To use the IIIF task, you will also need to have ImageMagick and Ghostscript installed and functional. You can check to see if you have ImageMagick by running:
```bash
$ convert -version
  Version: ImageMagick 6.9.9-20 Q16 x86_64 2017-10-15 http://www.imagemagick.org
  Copyright: ÂŠ 1999-2017 ImageMagick Studio LLC
  License: http://www.imagemagick.org/script/license.php
  Features: Cipher DPC Modules
  Delegates (built-in): bzlib freetype jng jpeg ltdl lzma png tiff xml zlib
```

... and check Ghostscript with:
```bash
$ gs -version
  GPL Ghostscript 9.21 (2017-03-16)
  Copyright (C) 2017 Artifex Software, Inc.  All rights reserved.
```

Next, you'll need a Jekyll site. You can clone the [minicomp/wax demo site](https://github.com/minicomp/wax/) or start a site from scratch with:

```sh
$ gem install jekyll
$ jekyll new wax && cd wax
```

## Installation

Add `wax_tasks` to your Jekyll site's `Gemfile`:

```ruby
gem 'wax_tasks'
```

... and install with bundler:

```bash
$ bundle install
```

Create a `Rakefile` with the following:
```ruby
spec = Gem::Specification.find_by_name 'wax_tasks'
Dir.glob("#{spec.gem_dir}/lib/tasks/*.rake").each { |r| load r }
```

# Usage

After following the installation instructions above, you will have access to the Rake tasks in your shell by running `$ bundle exec rake wax:taskname` in the root directory of your Jekyll site.

<br>
<img src="https://media.giphy.com/media/e7OR7qbQjF2ocNVS7V/giphy.gif"/>

## Sample site `_config.yml` file:

```yaml
# basic settings
title: Wax.
description: a jekyll theme for minimal exhibitions
url: ''
baseurl: '/wax'

# build settings
permalink: pretty # optional, creates `/page/` link instead of `page.html` links

# wax collection settings
collections:
  objects: # the collection name
    layout: 'iiif-image-page'
    output: true # this must be true for your .md pages to be built to html!
    metadata:
      source: 'objects.csv' # path to the metadata file, must be within '_data'
    images:
      source 'source_images/objects' # path to the directory of source images, must be within '_data'

# wax search index settings
lunr_index:
  - file: 'js/lunr-index.json' # where the index will be generated
    collections: # the collections to index
      objects:
        content: false # whether or not to index the markdown page content (below the YAML)
        fields: # the metadata fields to index
          - 'label'
          - 'artist'
          - 'location'
          - 'object_type'
```

The above example includes a single collection `objects` that comprises:
1. a CSV `metadata:source` file (`objects.csv`), and
2. a `images:source` directory of image and pdf files.

For more information on configuring Jekyll collections for __wax_tasks__, check out the [minicomp/wax wiki](https://minicomp.github.io/wiki/#/wax/) and <https://jekyllrb.com/docs/collections/>.

## Running the tasks

### wax:pagemaster

Takes a CSV, JSON, or YAML file of collection metadata and generates a [markdown](https://daringfireball.net/projects/markdown/syntax) page for each record to a directory using a specified layout. [Read More](https://minicomp.github.io/wiki/#/wax/tasks/pagemaster?id=top).

`$ bundle exec rake wax:pagemaster collection-name`

### wax:lunr

Generates a client-side JSON search index of your site for use with [ElasticLunr.js](http://elasticlunr.com/). [Read More](https://minicomp.github.io/wiki/#/wax/tasks/lunr?id=top).

`$ bundle exec rake wax:lunr`

```sh
------------------------------------------------------------------------
NOTE >> wax:lunr will also generate a default lunr UI to use
        if you add a ui path to your lunr index configuration
        with `ui: 'example/path-to-ui.js'` and run:

        $ bundle exec rake wax:lunr UI=true
------------------------------------------------------------------------
```

### wax:derivatives:simple

Takes a local directory of images and pdf files and generates a few image derivatives (i.e., 'thumbnail' 250w and 'full' 1140w) for Jekyll layouts and includes to use. [Read More]().

`$ bundle exec rake wax:derivatives:iiif collection-name`

### wax:derivatives:iiif

Takes a local directory of images and pdf files and generates tiles and data that work with a IIIF compliant image viewer like [OpenSeaDragon](https://openseadragon.github.io/), [Mirador](http://projectmirador.org/), or [Leaflet IIIF](https://github.com/mejackreed/Leaflet-IIIF). [Read More](https://minicomp.github.io/wiki/#/wax/tasks/iiif?id=top).

`$ bundle exec rake wax:derivatives:iiif collection-name`

### wax:test

Runs [`htmlproofer`](https://github.com/gjtorikian/html-proofer) on your compiled site to look for broken links, HTML errors, and accessibility concerns. Runs [Rspec](http://rspec.info/) tests if a `.rspec` file is present. [Read More](https://minicomp.github.io/wiki/#/wax/tasks/test?id=top).

`$ bundle exec rake wax:test`

# Contributing

Fork/clone the repository. After making code changes, run the tests (`$ bundle exec rubocop` and `$ bundle exec rspec`) before submitting a pull request. You can enable verbose tests with `$ DEBUG=true bundle exec rspec`.

> __Note:__ The cannonical repository is [minicomp/wax_tasks](https://github.com/minicomp/wax_tasks/). Please submit all issues and pull requests to the [minicomp/wax_tasks](https://github.com/minicomp/wax_tasks/) repo.


```sh
---------------------------------------------------------------------------
NOTE >> The cannonical repository is minicomp/wax_tasks.
        Please submit all issues and pull requests to the cannonical repo.
---------------------------------------------------------------------------
```
<p align="right"><a href='https://github.com/minicomp/wax_tasks/'>minicomp/wax_tasks ~></a></p>

# License

The gem is available as open source under the terms of the [MIT License](LICENSE).
