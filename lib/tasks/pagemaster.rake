require 'colorized_string'
require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    abort "Please specify a collection after 'wax:pagemaster'".magenta if args.empty?
    args.each do |collection_name|
      site_config = WaxTasks.site_config
      WaxTasks.pagemaster(collection_name, site_config)
    end
  end
end
