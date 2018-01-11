require 'jekyll'
require 'tmpdir'
require 'fileutils'
require 'colorized_string'

namespace :wax do
  desc 'build site with gh-baseurl and publish to gh-pages branch'
  task :ghbranch => :config do
    FileUtils.rm_rf('_site')

    baseurl = $config['gh-baseurl']

    Jekyll::Site.new(Jekyll.configuration({
      "source"      => ".",
      "destination" => "_site",
      "config" => "_config.yml",
      "baseurl" => baseurl,
      "incremental" => true,
      "verbose" => true
    })).process

    origin = `git config --get remote.origin.url`

    Dir.mktmpdir do |tmp|
      cp_r "_site/.", tmp
      Dir.chdir tmp

      system "git init" # Init the repo.
      system "git add . && git commit -m 'Site updated at #{Time.now.utc}'"
      system "git remote add origin #{origin}"
      system "git push origin master:refs/heads/gh-pages --force"
    end
  end
end
