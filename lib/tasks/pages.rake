# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pages do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    raise WaxTasks::Error::MissingArguments, 'You must specify a collection after wax:pagemaster' if args.empty?

    site = WaxTasks::Site.new

    args.each do |a|
      collection = WaxTasks::Collection.new(site, a)
      WaxTasks.generate_pages(collection)
    end
  end

  # alias :pagemaster to wax:pages for backwards compatibility
  task :pagemaster do
    t = Rake::Task['wax:pagemaster']
    desc t.full_comment if t.full_comment
    arguments = ARGV.drop(1).each { |a| task a.to_sym }
    t.invoke(*arguments)
  end
end
