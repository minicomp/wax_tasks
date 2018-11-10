require 'wax_tasks'

namespace :wax do
  namespace :derivatives do
    desc 'generate iiif derivatives from local image files'
    task :iiif do
      arguments = ARGV.drop(1).each { |a| task a.to_sym }
      raise WaxTasks::Error::MissingArguments, "You must specify a collection after 'wax:derivatives:iiif'" if arguments.empty?
      task_runner = WaxTasks::TaskRunner.new
      task_runner.derivatives_iiif(arguments)
    end
  end

  # alias wax:iiif to wax:derivatives:iiif for backwards compatibility
  task :iiif do
    t = Rake::Task['wax:derivatives:iiif']
    desc t.full_comment if t.full_comment
    arguments = ARGV.drop(1).each { |a| task a.to_sym }
    t.invoke(*arguments)
  end
end
