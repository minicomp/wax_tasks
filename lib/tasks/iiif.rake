include FileUtils
require 'wax_tasks'
require 'wax_iiif'

namespace :wax do
  task :iiif do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    site_config = WaxTasks.config
    abort "You must specify a collections after 'bundle exec rake wax:iiif'.".magenta if args.empty?
    WaxTasks.iiif(args, site_config)
  end
end
