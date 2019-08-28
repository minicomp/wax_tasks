# Changelog

Welcome to the Changelog! Below is the first attempt at a log for this project.  

Please note that we define ___breaking changes___ as those changes which force users to change how they interact with __wax_tasks__
via their site's `_config.yml` file or how they invoke the tasks on the command line.

## v1.0.3
#### Date: ???

#### Non-breaking Changes:
- :white_check_mark: Allows use of `wax_iiif < 0.3` (was `<0.2`)
- :white_check_mark: Fix bug where command options (e.g., `--trace`) were being parsed as task ARGV args.

## v1.0.2
#### Date: 06/12/2019

#### Non-breaking Changes:
- :white_check_mark: Fixes [32](https://github.com/minicomp/wax_tasks/issues/32); accepts narrow images (< 1140px)
- :white_check_mark: Fixes [33](https://github.com/minicomp/wax_tasks/issues/33); better image extension handling
- :white_check_mark: Fixes [34](https://github.com/minicomp/wax_tasks/issues/34); ^
- :white_check_mark: Fixes [36](https://github.com/minicomp/wax_tasks/issues/36); fixes bug if an image item doesn't have a record

## v1.0.1
#### Date: 06/05/2019

#### Non-breaking Changes:
- :white_check_mark: Uses `wax_iiif v0.1.2` with better progress bar handling on IIIF derivative generation
- :white_check_mark: Has better progress bar handling on simple derivative generation

## v1.0.0
#### Date: 06/04/2019

#### Breaking Changes:
- :bangbang: __Search index generation__ is now handled under the variable `search` in `_config.yml` instead of `lunr_index` and accepts a hash instead of an array.
- :bangbang: __Search index generation__ is now run with `bundle exec rake wax:search NAME` instead of `bundle exec rake wax:lunr`
- :x: __Search UI__ is now handled dynamically by `wax_theme`; as such the `UI=true` option on the rake task has been depricated.
- :x:: The __site testing__ task `bundle exec rake wax:test` was deprecated and moved to `wax_theme`, since it deals with site presentation and not the handling of collection data.
- :x: The `wax:jspackage` task was depricated, since it was arbitrary and unused.

#### Non-breaking Changes:
- :white_check_mark: The __page generation__ task `bundle exec rake wax:pagemaster NAME` has become `bundle exec rake wax:pages NAME`. However, this is currently aliased for backwards compatibility.
