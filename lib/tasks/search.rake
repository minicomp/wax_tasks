# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'build lunr search index (with default UI if UI=true)'
  task :search do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    args.reject! { |a| a.start_with? '-' }
    raise WaxTasks::Error::MissingArguments, Rainbow('You must specify a collection after wax:search').magenta if args.empty?

    site = WaxTasks::Site.new
    args.each { |a| site.generate_static_search a }
  end

  # alias lunr to search for backwards compatibility
  task :lunr do
    t = Rake::Task['wax:search']
    desc t.full_comment if t.full_comment
    args = ARGV.drop(1).each { |a| task a.to_sym }
    t.invoke(*args)
  end
end
