require 'fileutils'
require 'jekyll'
require 'yaml'

include FileUtils

module Fake
  def self.site
    site_dir = 'faker_site'
    mkdir_p(site_dir)
    data_dir = site_dir + '/_data'
    mkdir_p(data_dir)
    image_dir = Dir.glob('spec/data/iiif')
    cp_r(image_dir, data_dir)
    cd(site_dir)

    config_file = {
      'title'       => 'spec site',
      'url'         => '',
      'baseurl'     => '',
      'gh-baseurl'  => '/wax_tasks',
      'exclude'     => ['Rakefile'],
      'theme'       => 'minima',
      'js'          => { 'jquery' => { 'cdn' => 'test', 'version' => 'test' } }
    }

    File.open('_config.yml', 'w') { |f| f.puts(config_file.to_yaml) }
    File.open('Gemfile', 'w') do |f|
      f.puts("source 'https://rubygems.org'")
      f.puts("gem 'jekyll'")
      f.puts("gem 'minima'")
    end
    File.open('Rakefile', 'w') { |f| f.puts('Dir.glob("../lib/tasks/*.rake").each { |r| load r }') }
    File.open('index.html', 'w') { |f| f.puts('<!DOCTYPE html><html><head><meta charset="UTF-8"><title>spec site</title></head><body>Home</body></html>') }
    Bundler.with_clean_env { system('bundle > /dev/null') }
  end
end
