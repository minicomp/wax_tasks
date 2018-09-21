require 'wax_tasks'

namespace :wax do
  desc 'push compiled Jekyll site to git branch BRANCH'
  task :push do
    ARGS = ARGV.drop(1).each { |a| task a.to_sym }
    raise 'You must specify a branch after \'wax:push:branch\'' if ARGS.empty?

    task_runner = WaxTasks::TaskRunner.new
    task_runner.push_branch(ARGS.first)
  end
end
