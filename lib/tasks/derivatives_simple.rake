require 'wax_tasks'

namespace :wax do
  namespace :derivatives do
    desc 'generate iiif derivatives from local image files'
    task :simple do
      arguments = ARGV.drop(1).each { |a| task a.to_sym }
      raise WaxTasks::Error::MissingArguments, "You must specify a collection after 'wax:derivatives:simple'" if arguments.empty?
      task_runner = WaxTasks::TaskRunner.new
      task_runner.derivatives_simple(arguments)
    end
  end
end
