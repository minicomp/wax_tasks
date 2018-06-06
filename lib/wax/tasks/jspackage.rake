require 'wax_tasks'

namespace :wax do
  desc 'write a simple package.json'
  task :jspackage do
    s_conf = WaxTasks.site_config
    if s_conf[:js]
      names = []
      package = {
        'name'          => s_conf['title'],
        'version'       => '1.0.0',
        'dependencies'  => {}
      }
      s_conf[:js].each do |dependency|
        name = dependency[0]
        names << name
        version = dependency[1]['version']
        package['dependencies'][name] = '^' + version
      end
      File.open('package.json', 'w') { |file| file.write(package.to_json) }
      Message.writing_package_json(names)
    else
      Message.skipping_package_json
    end
  end
end
