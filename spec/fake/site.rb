require 'fileutils'
require 'jekyll'
require 'yaml'

include FileUtils

site_dir = 'faker_site'
mkdir_p(site_dir)
data_dir = site_dir + '/_data'
mkdir_p(data_dir)
image_dir = Dir.glob('spec/data/iiif')
cp_r(image_dir, data_dir)
cd(site_dir)

config_file = {
  'title'       => 'faker',
  'url'         => '',
  'baseurl'     => '',
  'exclude'     => ['Rakefile']
}
config_opts = {
  'source'      => '.',
  'destination' => '_site',
  'config'      => '_config.yml'
}

File.open('_config.yml', 'w') { |f| f.puts(config_file.to_yaml) }
File.open('Rakefile', 'w') { |f| f.puts('Dir.glob("../lib/tasks/*.rake").each { |r| load r }') }
Jekyll::Site.new(Jekyll.configuration(config_opts)).process
