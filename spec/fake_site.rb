require 'fileutils'
require 'jekyll'
require 'yaml'

include FileUtils

mkdir_p('faker_site')
cd('faker_site')

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
File.open('Rakefile', 'w') { |f| f.puts('Dir.glob("../lib/tasks/*.rake").each { |r| load r }') }
Jekyll::Site.new(Jekyll.configuration(conf)).process
