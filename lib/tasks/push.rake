require 'wax_tasks'

namespace :wax do
  desc 'push compiled Jekyll site to git branch BRANCH'
  task :push do
    arguments = ARGV.drop(1).each { |a| task a.to_sym }
    raise WaxTasks::Error::MissingArguments, 'You must specify a branch after wax:push' if arguments.empty?

    task_runner = WaxTasks::TaskRunner.new
    task_runner.push_branch(arguments.first)
  end
end
