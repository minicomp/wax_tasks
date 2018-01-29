# wax_tasks
[![Gem Version](https://badge.fury.io/rb/wax_tasks.svg)](https://badge.fury.io/rb/wax_tasks) [![Dependency Status](https://gemnasium.com/badges/github.com/mnyrop/wax_tasks.svg)](https://gemnasium.com/github.com/mnyrop/wax_tasks) [![Build Status](https://travis-ci.org/mnyrop/wax_tasks.svg?branch=rubocop)](https://travis-ci.org/mnyrop/wax_tasks)



#### A gem-packaged set of [Rake](https://ruby.github.io/rake/) tasks for creating minimal exhibitions with [Jekyll](https://jekyllrb.com/), [IIIF](http://iiif.io), and [ElasticLunr.js](http://elasticlunr.com/).

Looking for a Jekyll theme with [wax_tasks]() functionality baked in? Check out [minicomp/wax](https://minicomp.github.io/wax/). Or, do you want *truly* minimal exhibitions without IIIF? Check out [miniwax_tasks](https://github.com/mnyrop/miniwax_tasks).

<br>
<img src="https://github.com/mnyrop/wax_tasks/blob/master/docs/wax_screen.gif?raw=true"/>


#### Getting Started
- [Prerequisites](#prerequisites)
- [Installing](#installing)

#### Running the tasks
- [wax:pagemaster](#waxpagemaster)
- [wax:lunr](#waxlunr)
- [wax:iiif](#waxiiif)
- [wax:test](#waxtest)

#### To Do
- [v0.5.0](#050-release)


# Getting Started

## Prerequisites

You'll need `Ruby >= 2.2` with `bundler` and `jekyll` installed. Check your versions with:
```bash
$ ruby -v
  ruby 2.4.2p198 (2017-09-14 revision 59899) [x86_64-darwin15]

$ jekyll -v
  jekyll 3.7.0

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
source 'https://rubygems.org'
gem 'wax_tasks'
```

... and install with bundler:

```bash
$ bundle install
```

Create a `Rakefile` with the following:
```ruby
spec = Gem::Specification.find_by_name 'wax_tasks'
Dir.glob("#{spec.gem_dir}/lib/tasks/*.rake").each {|r| load r}
```

# Running the Tasks

After following the installation instructions above, you will have access to the rake tasks in your shell by running `$ bundle exec rake wax:<taskname>` in the root directory of your Jekyll site.


## wax:pagemaster

Takes a CSV file of metadata and generates a Markdown page for each record to a specified directory and using a specified layout. [Read More](docs/pagemaster.md).

## wax:lunr

Generates a client-side JSON search index of your site for use with [ElasticLunr.js](http://elasticlunr.com/).

## wax:iiif

Takes a local directory of images and generates tiles and data that work with a IIIF compliant image viewer like [OpenSeaDragon](https://openseadragon.github.io/).

## wax:test

Runs [`htmlproofer`](https://github.com/gjtorikian/html-proofer) on your compiled site to look for broken links, HTML errors, and accessibility concerns. Runs [Rspec](http://rspec.info/) tests if a `.rspec` file is present.

# Contributing

Fork/clone the repository. After making code changes, run the tests (`$ bundle exec rubocop` and `$ bundle exec rspec`) before submitting a PR.


# To Do
## 0.5.0 alpha release

- [x] `content: true/false` on collection level (instead of index level) for `wax:lunr` task.
- [ ] generate default `js/lunr-ui.js` if `!exist?` on `wax:lunr` task.
- [x] write spec for `wax:iiif` on sample HQ .jpgs.
- [ ] create umbrella `wax:process` task, that would run `wax:pagemaster <collection` and regenerate the lunr index with `wax:lunr`.
- [ ] make `wax:pagemaster` accept json.
- [ ] change `_iiif` file structure to `_iiif/collection_name/source_images/*` and generate to `_iiif/collection_name/tiles/*`.
- [ ] better process content in lunr index
