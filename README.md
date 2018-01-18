# wax_tasks
[![Gem Version](https://badge.fury.io/rb/wax_tasks.svg)](https://badge.fury.io/rb/wax_tasks) [![Dependency Status](https://gemnasium.com/badges/github.com/mnyrop/wax_tasks.svg)](https://gemnasium.com/github.com/mnyrop/wax_tasks) [![Build Status](https://travis-ci.org/mnyrop/wax_tasks.svg?branch=rubocop)](https://travis-ci.org/mnyrop/wax_tasks)


##### A gem-packaged set of [Rake](https://ruby.github.io/rake/) tasks for creating minimal exhibitions with [Jekyll](https://jekyllrb.com/), [IIIF](http://iiif.io), and [ElasticLunr.js](http://elasticlunr.com/).


Looking for a Jekyll theme with `wax_tasks` functionality basked in? Check out [Minicomp/Wax](https://minicomp.github.io/wax/). Want *truly* minimal exhibitions, without IIIF? Check out [miniwax_tasks](https://github.com/mnyrop/miniwax_tasks).

## Getting Started

### Prerequisites

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

### Installing

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

## The tasks

After following the installation instructions above, you will have access to the rake tasks in your shell by running `$ bundle exec rake wax:<taskname>` in the root directory of your Jekyll site.


### `wax:pagemaster`

#### What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

#### Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

#### Configuration

Add to `_config.yml`:
```yaml
collections:
  paintings:
    output: true
    source: paintings-metadata.csv
    directory: paintings
    layout: painting-page
  artists:
    output: true
    source: artist-data.yaml
    directory: artists
    layout: author-info-page
```

#### To use
`$ bundle exec rake wax:pagemaster <collection>`

### `wax:lunr`

#### What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

#### Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

#### Configuration

Add to `_config.yml`:
```yaml
lunr:
  content: true
  multi-language: true
  meta:
    - dir: projects
      fields:
        - title
        - era
        - tags
    - dir: _posts
      fields:
        - title
        - category
        - tags
```

#### To use
`$ bundle exec rake wax:lunr`

### `wax:iiif`

#### What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

#### Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.


#### Configuration
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

#### To use
`$ bundle exec rake wax:iiif`

### `wax:test`

#### What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

#### Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

#### To use
`$ bundle exec rake wax:test`
