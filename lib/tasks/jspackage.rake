require 'colorized_string'
require 'json'

require 'wax_tasks'

namespace :wax do
  desc 'write a simple package.json'
  task :jspackage do
    site_config = WaxTasks.site_config
    package = {
      'name'          => site_config['title'],
      'version'       => '1.0.0',
      'description'   => site_config['description'],
      'dependencies'  => {}
    }
    names = []
    site_config['js'].each do |dependency|
      name = dependency[0]
      names << name
      version = dependency[1]['version']
      package['dependencies'][name] = '^' + version
    end
    File.open('package.json', 'w') { |file| file.write(package.to_json) }
    puts "Writing #{names} to simple package.json.".cyan
  end
end
