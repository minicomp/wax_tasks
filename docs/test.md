# wax:test

## What it does
[`htmlproofer`](https://github.com/gjtorikian/html-proofer) on your compiled site to look for broken links, HTML errors, and accessibility concerns. Runs [Rspec](http://rspec.info/) tests if a `.rspec` file is present.

## Requirements
`html-proofer` gem (comes with `wax_tasks`). BYO rspec tests.

## To use
`$ bundle exec rake wax:test`
