# wax_tasks
[![Gem Version](https://badge.fury.io/rb/wax_tasks.svg)](https://badge.fury.io/rb/wax_tasks) [![Dependency Status](https://gemnasium.com/badges/github.com/mnyrop/wax_tasks.svg)](https://gemnasium.com/github.com/mnyrop/wax_tasks) [![Build Status](https://travis-ci.org/mnyrop/wax_tasks.svg?branch=rubocop)](https://travis-ci.org/mnyrop/wax_tasks)

#### A gem-packaged set of [Rake](https://ruby.github.io/rake/) tasks for creating minimal exhibitions with [Jekyll](https://jekyllrb.com/), [IIIF](http://iiif.io), and [ElasticLunr.js](http://elasticlunr.com/).

Looking for a Jekyll theme with [wax_tasks]() functionality baked in? Check out [minicomp/wax](https://minicomp.github.io/wax/). Or, do you want *truly* minimal exhibitions without IIIF? Check out [miniwax_tasks](https://github.com/mnyrop/miniwax_tasks).

<br>
<img src="https://github.com/mnyrop/wax_tasks/blob/master/wax_screen.gif"/>

#### Getting Started
- [Prerequisites](#prerequisites)
- [Installing](#installing)
#### The tasks
- [wax:pagemaster](#waxpagemaster)
- [wax:lunr](#waxlunr)
- [wax:iiif](#waxiiif)
- [wax:test](#waxtest)


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

# The tasks

After following the installation instructions above, you will have access to the rake tasks in your shell by running `$ bundle exec rake wax:<taskname>` in the root directory of your Jekyll site.


## wax:pagemaster

### What it does
Takes a CSV file of metadata and generates a Markdown page for each record to a specified directory and using a specified layout. If a Markdown page already exists, pagemaster will skip over it and not overwrite the data. (e.g. to regenrate pages, delete them first.)

### Requirements
One CSV file of metadata per collection. Each file MUST have a column called `pid` of persistent, unique identifiers for the records, which CANNOT have spaces or special characters since they will be used to name the pages. Each file MUST have a column called `title`, which will be used for the Lunr search results display. Column names CANNOT have spaces or special characters. Please use camel_case format, e.g. `current_primary_location` instead of `current / primary location`.

**Note:** Some fields are used by Jekyll for specific tasks, and should not be used as metadata headers (e.g. `name`,`id`, and `date`). If you need to use these terms to name your columns, prepend them with an underscore: `_date`.

**For example:** `_data/objects.csv`

| pid | iiif_image | artist                      | location | title                               | _date        | object_type | current_location                   | wiki_link                                                                                                                                            | 
|-----|------------|-----------------------------|----------|-------------------------------------|--------------|-------------|------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------| 
| 1   | 1          | Al-Hajj Hafiz Muhammad Nuri | Turkey   | The Dala'il al-Khayrat of al-Juzuli | 1801         | manuscript  | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Al-Hajj_Hafiz_Muhammad_Nuri,_Turkey,_1801_-_The_Dala%27il_al-Khayrat_of_al-Juzuli_-_Google_Art_Project.jpg" | 
| 2   | 2          | Mihr 'Ali                   | Iran     | Portrait of Fath 'Ali Shah          | 1816         | portrait    | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Mihr_%27Ali,_Iran,_1816_-_Portrait_of_Fath_%27Ali_Shah_-_Google_Art_Project.jpg"                            | 
| 3   | 3          | Unknown                     | Egypt    | Sulwan Al-Muta'a                    | 14th century | manuscript  | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Unknown,_Egypt_or_Syria,_14th_Century_-_Sulwan_Al-Muta%27a_-_Google_Art_Project.jpg"                        | 
| 4   | 4          | Unknown                     | Egypt    | Map of the World                    | 15th century | map         | "The Museum of Islamic Art, Qatar" | "https://commons.wikimedia.org/wiki/File:Unknown,_Egypt,_15th_Century_-_Map_of_World_-_Google_Art_Project.jpg"                                       | 



### Configuration

Put your metadata file(s) in the `_data` directory, and add the info to `collections` in `_config.yml`:
```yaml
collections:
  objects:
    source: objects.csv
    directory: objects
    layout: iiif-image-page
```

### To use
`$ bundle exec rake wax:pagemaster <collection>`

(For the above example, `$ bundle exec rake wax:pagemaster objects` would generate pages with the `iiif-image-page.html` layout to the directory `objects` from `_data/objects.csv`.

## wax:lunr

### What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

### Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

### Configuration

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

### To use
`$ bundle exec rake wax:lunr`

## wax:iiif

### What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

### Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.


### Configuration
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

### To use
`$ bundle exec rake wax:iiif`

## wax:test

### What it does
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

### Requirements
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

### To use
`$ bundle exec rake wax:test`


## To do (for v1.0)

- [ ] `content: true/false` on collection level (instead of index level) for `wax:lunr` task. 
- [ ] generate default `js/lunr-ui.js` if `!exist?` on `wax:lunr` task. 
- [ ] write spec for `wax:iiif` on sample HQ .jpgs.
- [ ] create umbrella `wax:process` task, that would run `wax:pagemaster <collection` and regenerate the lunr index with `wax:lunr`.
- [ ] rewrite `wax:iiif` to tie with collections config and use rake argvs.
