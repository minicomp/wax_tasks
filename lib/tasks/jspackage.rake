require 'wax_tasks'

namespace :wax do
  desc 'write a simple package.json'
  task :jspackage do
    site_config = WaxTasks::SITE_CONFIG
    if site_config[:js]
      names = []
      package = {
        'name'          => site_config['title'],
        'version'       => '1.0.0',
        'dependencies'  => {}
      }
      site_config[:js].each do |dependency|
        name = dependency[0]
        names << name
        version = dependency[1]['version']
        package['dependencies'][name] = '^' + version
      end
      File.open('package.json', 'w') { |file| file.write(package.to_json) }
    end
  end
end
