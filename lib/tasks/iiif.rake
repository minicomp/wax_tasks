require 'wax_tasks'

namespace :wax do
  desc 'generate iiif derivatives from local image files'
  task :iiif do
    ARGS = ARGV.drop(1).each { |a| task a.to_sym }
    abort "You must specify a collection after 'wax:iiif'" if ARGS.empty?
    task_runner = WaxTasks::TaskRunner.new
    task_runner.iiif(ARGS)
  end
end
