require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    site_config = WaxTasks.config
    if args.empty?
      abort "You must specify one or more collections after 'rake wax:pagemaster' to generate.".magenta
    else
      args.each { |a| WaxTasks.pagemaster(a, site_config) }
    end
  end
end
