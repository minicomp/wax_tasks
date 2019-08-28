# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pages do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    args.reject! { |a| a.start_with? '-' }
    raise WaxTasks::Error::MissingArguments, Rainbow('You must specify a collection after wax:pages').magenta if args.empty?

    site = WaxTasks::Site.new
    args.each { |a| site.generate_pages a }
  end

  # alias :pagemaster to wax:pages for backwards compatibility
  task :pagemaster do
    t = Rake::Task['wax:pages']
    desc t.full_comment if t.full_comment
    args = ARGV.drop(1).each { |a| task a.to_sym }
    t.invoke(*args)
  end
end
