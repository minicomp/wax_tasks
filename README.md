# wax_tasks 🐝
[![ci:test](https://github.com/minicomp/wax_tasks/actions/workflows/ci.yml/badge.svg)](https://github.com/minicomp/wax_tasks/actions/workflows/ci.yml) [![Depfu](https://badges.depfu.com/badges/6105c55b9634e74b1c27055b19bad8f0/overview.svg)](https://depfu.com/github/minicomp/wax_tasks?project_id=10548)
[![Gem Version](https://badge.fury.io/rb/wax_tasks.svg)](https://badge.fury.io/rb/wax_tasks)
[![Gem Downloads](https://img.shields.io/gem/dt/wax_tasks.svg?color=046d0b)](https://badge.fury.io/rb/wax_tasks)
[![docs](http://img.shields.io/badge/docs-rdoc.info-blue.svg?style=flat)](https://www.rubydoc.info/github/minicomp/wax_tasks/)

[![Maintainability](https://api.codeclimate.com/v1/badges/14408e7e962b9b84ec65/maintainability)](https://codeclimate.com/github/minicomp/wax_tasks/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/14408e7e962b9b84ec65/test_coverage)](https://codeclimate.com/github/minicomp/wax_tasks/test_coverage)
![License](https://img.shields.io/github/license/minicomp/wax_tasks.svg?color=c6a1e0)

__wax_tasks__ is gem-packaged set of [Rake](https://ruby.github.io/rake/) tasks for creating minimal exhibition sites with [Wax](https://github.com/minicomp/wax/).

It can be used to:
- generate collection markdown pages from a metadata file ([wax:pages](#waxpages))
- generate a client-side search index ([wax:search](#waxsearch))
- generate either IIIF-compliant derivatives ([wax:derivatives:iiif](#waxderivativesiiif)) or simple image derivatives ([wax:derivatives:simple](#waxderivativessimple)) from local image and pdf files

<br>
<img src="https://raw.githubusercontent.com/minicomp/wiki/main/src/assets/wax_screen.gif?raw=true?raw=true"/>


# Getting Started

## Prerequisites

You'll need `Ruby >= 2.4` with `bundler` installed. Check your versions with:
```bash
$ ruby -v
  ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-darwin18]

$ bundler -v
  Bundler version 1.16.1
```

To use the image derivative tasks, you will also need to have ImageMagick and Ghostscript installed and functional. You can check to see if you have ImageMagick by running:
```bash
$ convert -version
  Version: ImageMagick 6.9.9-20 Q16 x86_64 2017-10-15 http://www.imagemagick.org
  Copyright: (c) 1999-2017 ImageMagick Studio LLC
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
To see the available tasks, run

```ruby
$ bundle exec rake --tasks
```

## Sample site `_config.yml` file:

```yaml
# basic settings
title: Wax.
description: a jekyll theme for minimal exhibitions
url: 'https://minicomp.github.io'
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
search:
  main:
    index: 'js/lunr-index.json' # where the index will be generated
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

### wax:pages

Takes a CSV, JSON, or YAML file of collection metadata and generates a [markdown](https://daringfireball.net/projects/markdown/syntax) page for each record to a directory using a specified layout. [Read More](#TODO).

`$ bundle exec rake wax:pages collection-name`

### wax:search

Generates a client-side JSON search index of your site for use with [ElasticLunr.js](http://elasticlunr.com/). [Read More](#TODO).

`$ bundle exec rake wax:search search-name`


### wax:derivatives:simple

Takes a local directory of images and pdf files and generates a few image derivatives (i.e., 'thumbnail' 250w and 'full' 1140w) for Jekyll layouts and includes to use. [Read More](#TODO).

`$ bundle exec rake wax:derivatives:iiif collection-name`

### wax:derivatives:iiif

Takes a local directory of images and pdf files and generates tiles and data that work with a IIIF compliant image viewer like [OpenSeaDragon](https://openseadragon.github.io/), [Mirador](http://projectmirador.org/), or [Leaflet IIIF](https://github.com/mejackreed/Leaflet-IIIF). [Read More](#TODO).

`$ bundle exec rake wax:derivatives:iiif collection-name`

### wax:clobber

Destroys (or "clobbers") wax-generated files, i.e., pages generated from `wax:pagemaster`, derivatives generated from `wax:derivatives`, and search indexes generated with `wax:search` so you can start from scratch.

This task does *not* touch your source metadata or source image files! Instead, it simply clears a path for you to regenerate your collection materials in case you add/edit source materials.

`$ bundle exec rake wax:clobber collection-name`

# Contributing

Fork/clone the repository. After making code changes, run the tests (`$ bundle exec rubocop` and `$ bundle exec rspec`) before submitting a pull request. You can enable verbose tests with `$ DEBUG=true bundle exec rspec`.

# License

The gem is available as open source under the terms of the [MIT License](LICENSE).
