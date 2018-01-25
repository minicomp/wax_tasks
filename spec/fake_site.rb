require 'fileutils'
require 'jekyll'
require 'yaml'

include FileUtils

site_dir = 'faker_site'
mkdir_p(site_dir)
test_images = Dir.glob('spec/_iiif')
cp_r(test_images, site_dir)
cd(site_dir)

config = {
  'title'       => 'faker',
  'url'         => '',
  'baseurl'     => '',
  'exclude'     => ['Rakefile']
}
conf = {
  'source'      => '.',
  'destination' => '_site',
  'config'      => '_config.yml'
}

File.open('_config.yml', 'w') { |f| f.puts(config.to_yaml) }
Jekyll::Site.new(Jekyll.configuration(conf)).process
