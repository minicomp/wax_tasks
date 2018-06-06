# wax_tasks
[![Gem Version](https://badge.fury.io/rb/wax_tasks.svg)](https://badge.fury.io/rb/wax_tasks) ![Libraries.io for GitHub](https://img.shields.io/librariesio/github/mnyrop/wax_tasks.svg)
[![Build Status](https://travis-ci.org/mnyrop/wax_tasks.svg?branch=rubocop)](https://travis-ci.org/mnyrop/wax_tasks) [![Maintainability](https://api.codeclimate.com/v1/badges/5974d49e115dadf9f8df/maintainability)](https://codeclimate.com/github/mnyrop/wax_tasks/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/5974d49e115dadf9f8df/test_coverage)](https://codeclimate.com/github/mnyrop/wax_tasks/test_coverage)

#### A gem-packaged set of [Rake](https://ruby.github.io/rake/) tasks for creating minimal exhibitions with [Jekyll](https://jekyllrb.com/), [IIIF](http://iiif.io), and [ElasticLunr.js](http://elasticlunr.com/).

Looking for a Jekyll theme that works with [wax_tasks]()? Check out [minicomp/wax](https://minicomp.github.io/wax/).

<br>
<img src="https://raw.githubusercontent.com/minicomp/wiki/master/docs/assets/wax_screen.gif">


#### Getting Started
- [Prerequisites](#prerequisites)
- [Installing](#installing)

#### Running the tasks
- [wax:pagemaster](#waxpagemaster)
- [wax:lunr](#waxlunr)
- [wax:iiif](#waxiiif)
- [wax:test](#waxtest)


# Getting Started

## Prerequisites

You'll need `Ruby >= 2.2` with `bundler` installed. Check your versions with:
```bash
$ ruby -v
  ruby 2.4.2p198 (2017-09-14 revision 59899) [x86_64-darwin15]

$ bundler -v
  Bundler version 1.16.1
```

To use the IIIF task, you will also need to have ImageMagick installed and functional. You can check to see if you have ImageMagick by running:
```bash
$ convert -version
  Version: ImageMagick 6.9.9-20 Q16 x86_64 2017-10-15 http://www.imagemagick.org
  Copyright: © 1999-2017 ImageMagick Studio LLC
  License: http://www.imagemagick.org/script/license.php
  Features: Cipher DPC Modules
  Delegates (built-in): bzlib freetype jng jpeg ltdl lzma png tiff xml zlib
```

## Installing

Add `wax_tasks` to your Jekyll site's Gemfile:

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
Dir.glob("#{spec.gem_dir}/lib/wax/tasks/*.rake").each { |r| load r }
```

# Running the Tasks

After following the installation instructions above, you will have access to the rake tasks in your shell by running `$ bundle exec rake wax:taskname` in the root directory of your Jekyll site.


## wax:pagemaster

Takes a CSV or JSON file of collection metadata and generates a Markdown page for each record to a directory using a specified layout. [Read More](https://minicomp.github.io/wiki/#/wax/tasks/pagemaster?id=top).

`$ bundle exec rake wax:pagemaster collection-name`

## wax:lunr

Generates a client-side JSON search index of your site for use with [ElasticLunr.js](http://elasticlunr.com/). [Read More](https://minicomp.github.io/wiki/#/wax/tasks/lunr?id=top).

`$ bundle exec rake wax:lunr`

## wax:iiif

Takes a local directory of images and generates tiles and data that work with a IIIF compliant image viewer like [OpenSeaDragon](https://openseadragon.github.io/), [Mirador](http://projectmirador.org/), or [Leaflet IIIF](https://github.com/mejackreed/Leaflet-IIIF). [Read More](https://minicomp.github.io/wiki/#/wax/tasks/iiif?id=top).

`$ bundle exec rake wax:iiif collection-name`

## wax:test

Runs [`htmlproofer`](https://github.com/gjtorikian/html-proofer) on your compiled site to look for broken links, HTML errors, and accessibility concerns. Runs [Rspec](http://rspec.info/) tests if a `.rspec` file is present. [Read More](https://minicomp.github.io/wiki/#/wax/tasks/test?id=top).

`$ bundle exec rake wax:test`

# Sample \_config.yml file:

```yaml
# basic settings
title: Wax.
description: a jekyll theme for minimal exhibitions
url: ''
baseurl: '/wax'

# build settings
permalink: pretty # optional, creates `/page/` link instead of `page.html` link
collections_dir: false # optional, allows you to tidy up and keep collections (below) inside a directory (as of jekyll 3.7)

# wax collection settings
collections:
  objects: # << the collection name, which will be the directory pagemaster makes
    source: objects.csv # ^^ it will also be used in creating permalinks for the pages
    layout: iiif-image-page
    output: true # this must be true for your .md pages to be built to html!
    lunr_index:
      content: false
      fields: [title, artist, location, _date, object_type, current_location]
    iiif:
      meta:
        label: title
        location: current_location
```

# Contributing

Fork/clone the repository. After making code changes, run the tests (`$ bundle exec rubocop` and `$ bundle exec rspec`) before submitting a PR.

> __Note:__ The cannonical repository is [minicomp/wax_tasks](https://github.com/minicomp/wax_tasks/). Please submit all issues and pull requests to the Minicomp repo.
