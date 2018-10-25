require 'wax_tasks'

namespace :wax do
  desc 'write a simple package.json for monitoring js dependencies'
  task :jspackage do
    task_runner = WaxTasks::TaskRunner.new
    package = task_runner.js_package
    unless package.empty?
      src  = task_runner.site[:source_dir]
      path = WaxTasks::Utils.make_path(src, 'package.json')
      File.open(path, 'w') { |f| f.write(package.to_json) }
    end
  end
end
