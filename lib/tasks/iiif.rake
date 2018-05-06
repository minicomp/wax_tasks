require 'colorized_string'
require 'wax_tasks'

namespace :wax do
  task :iiif do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    abort "Please specify a collections after 'wax:iiif'".magenta if args.empty?
    site_config = WaxTasks.site_config
    args.each { |collection_name| WaxTasks.iiif(collection_name, site_config) }
  end
end
