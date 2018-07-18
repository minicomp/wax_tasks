require 'wax_tasks'
require 'optparse'

namespace :wax do
  desc 'build lunr search index (with default UI if UI=true)'
  task :lunr do
    task_runner = WaxTasks::TaskRunner.new
    task_runner.lunr(generate_ui: !!ENV['UI'])
  end
end
