require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    ARGS = ARGV.drop(1).each { |a| task a.to_sym }
    raise 'You must specify a collection after wax:pagemaster' if ARGS.empty?
    ARGS.each do |name|
      collection = WaxTasks::PagemasterCollection.new(name)
      collection.generate_pages
    end
  end
end
