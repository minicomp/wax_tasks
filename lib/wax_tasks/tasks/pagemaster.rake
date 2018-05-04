require 'colorized_string'
require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    site_config = WaxTasks.config
    if args.empty?
      abort "Please specify a collection after 'wax:pagemaster'".magenta
    else
      args.each { |a| WaxTasks.pagemaster(a, site_config) }
    end
  end
end
