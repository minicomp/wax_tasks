require 'colorized_string'
require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    if args.empty?
      abort "Please specify a collection after 'wax:pagemaster'".magenta
    else
      args.each do |a|
        site_config = WaxTasks.site_config
        opts = WaxTasks.collection_config(a)
        collection = WaxTasks::Collection.new(opts)
        records = Pagemaster.ingest(collection.source)
        Pagemaster.generate(collection, records)
      end
    end
  end
end
