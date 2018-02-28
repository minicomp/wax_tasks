require 'wax_tasks'
require 'json'

namespace :wax do
  desc 'write a simple package.json'
  task :jspackage => :config do
    package = {
      'name'          => $config['title'],
      'version'       => '1.0.0',
      'description'   => $config['description'],
      'dependencies'  => {}
    }
    names = []
    config['js'].each do |dependency|
      name = dependency[0]
      names << name
      version = dependency[1]['version']
      package['dependencies'][name] = '^' + version
    end
    File.open('package.json', 'w') { |file| file.write(package.to_json) }
    puts "Writing #{names} to simple package.json.".cyan
  end
end
