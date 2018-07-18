require 'wax_tasks'

namespace :wax do
  desc 'write a simple package.json'
  task :jspackage do
    task_runner = WaxTasks::TaskRunner.new
    package = task_runner.js_package
    unless package.empty?
      path = WaxTasks::Utils.make_path(task_runner.site[:source_dir],
                                       'package.json')
      File.open(path, 'w') { |f| f.write(package.to_json) }
    end
  end
end
