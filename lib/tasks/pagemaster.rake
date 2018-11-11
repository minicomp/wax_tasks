require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    arguments = ARGV.drop(1).each { |a| task a.to_sym }
    raise WaxTasks::Error::MissingArguments, 'You must specify a collection after wax:pagemaster' if arguments.empty?
    task_runner = WaxTasks::TaskRunner.new
    task_runner.pagemaster(arguments)
  end
end
