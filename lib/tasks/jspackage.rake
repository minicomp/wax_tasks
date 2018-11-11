require 'json'
require 'wax_tasks'

namespace :wax do
  desc 'write a simple package.json for monitoring js dependencies'
  task :jspackage do
    task_runner = WaxTasks::TaskRunner.new
    package = task_runner.js_package
    unless package.empty?
      src_dir = task_runner.site[:source_dir]
      path    = WaxTasks::Utils.root_path(src_dir, 'package.json')

      puts "Writing javascript dependencies to #{path}".cyan
      File.open(path, 'w') { |f| f.write(JSON.pretty_generate(package)) }
    end
  end
end
