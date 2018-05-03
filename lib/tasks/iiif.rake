require 'wax_iiif'
require 'colorized_string'

require 'wax_tasks'

namespace :wax do
  task :iiif do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    site_config = WaxTasks.config
    abort "Please specify a collections after 'wax:iiif'".magenta if args.empty?
    WaxTasks.iiif(args, site_config)
  end
end
