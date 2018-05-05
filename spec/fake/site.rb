require 'fileutils'
require 'jekyll'
require 'yaml'

module Fake
  def self.site
    site_dir = 'build'
    data_dir = site_dir + '/_data'
    image_dir = Dir.glob('spec/data/iiif')

    FileUtils.mkdir_p(site_dir)
    FileUtils.mkdir_p(data_dir)
    FileUtils.cp_r(image_dir, data_dir)
    FileUtils.cd(site_dir)

    config_file = {
      'url' => '',
      'decription' => '',
      'collections_dir' => 'collections',
      'theme' => 'minima',
      'js' => {
        'jquery' => {
          'cdn' => 'test',
          'version' => 'test'
        }
      }
    }

    File.open('_config.yml', 'w') { |f| f.puts(config_file.to_yaml) }
    File.open('Gemfile', 'w') do |f|
      f.puts("source 'https://rubygems.org'")
      f.puts("gem 'jekyll'")
      f.puts("gem 'minima'")
    end
    File.open('Rakefile', 'w') do |f|
      f.puts('Dir.glob("../lib/tasks/*.rake").each { |r| load r }')
    end
    File.open('index.html', 'w') do |f|
      f.puts('<html><head></head><body>Home</body></html>')
    end
    Bundler.with_clean_env { system('bundle > /dev/null') }
  end
end
