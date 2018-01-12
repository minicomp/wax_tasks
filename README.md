# wax_tasks [![Gem Version](https://badge.fury.io/rb/wax_tasks.svg)](https://badge.fury.io/rb/wax_tasks) [![Dependency Status](https://gemnasium.com/badges/github.com/mnyrop/wax_tasks.svg)](https://gemnasium.com/github.com/mnyrop/wax_tasks)

## [minicomp](https://github.com/minicomp) rake tasks for jekyll [wax](https://minicomp.github.io/wax)

### current tasks:

`wax:pagemaster`: generates markdown pages for jekyll collections from csv or yaml files. (same as [`pagemaster`](https://github.com/mnyrop/pagemaster) gem).

`wax:iiif`: generates iiif image tiles and associated json for jekyll collections from local jpgs. (uses [`iiif_s3`](https://github.com/cmoa/iiif_s3) gem).

`wax:ghbranch`: builds your jekyll site and overwrites the `gh-pages` branch to publish your compiled `_site` directory with `gh-baseurl`.

`wax:s3branch`: builds your jekyll site and overwrites the `s3` branch to publish your compiled `_site` directory with `baseurl`.

`wax:lunr` builds a Lunrjs search index for your site.

`wax:test` runs htmlproofer and, if there is an .rspec file, runs your rspec tests.


### set-up:
1. add the `wax_tasks` gem to your jekyll site's `Gemfile` and install with `bundle install`:
```
 gem 'wax_tasks'
```
2. Create a `Rakefile` in the root of your jekyll site and add the following to load the wax_tasks:
```
spec = Gem::Specification.find_by_name 'wax_tasks'
Dir.glob("#{spec.gem_dir}/lib/tasks/*.rake").each {|r| load r}
```
3. Configure the collection information in your site's `_config.yaml`.
```yaml
# Collection params for wax:pagemaster
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
4. If generating a Lunrjs search index, add Lunr Params to `_config.yaml`.
```bash
# Lunr Search Params (for wax:lunr)
lunr:
  content: true
  multi-language: true
  meta:
    - dir: "_projects"
      permalink: "/projects"
      fields:
        - title
        - era
        - tags
    - dir: "_posts"
      permalink: "posts"
      fields:
        - title
        - category
        - tags
```
### to use:
```bash
$ bundle exec rake wax:<task_name> <option>
```
#### ex 1: generate md pages for `paintings` and `artists` from data files
```bash
$ bundle exec rake wax:pagemaster paintings artists
```
#### ex 2: generate iiif image tiles and associated json for `paintings` from local jpgs:
```bash
$ bundle exec rake wax:iiif paintings
```
#### ex 3: publish `_site` to `gh-pages` branch
```bash
$ bundle exec rake wax:ghbranch
```
#### ex 4: publish `_site` to `s3` branch
```bash
$ bundle exec rake wax:s3branch
```
#### ex 5: (re)generate lunrjs search index
```bash
$ bundle exec rake wax:lunr
```
#### ex 6: run CI test(s)
```bash
$ bundle exec rake wax:test
```
