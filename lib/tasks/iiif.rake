require 'wax_iiif'
require 'colorized_string'

require 'wax_tasks'

namespace :wax do
  task :iiif do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    abort "Please specify a collections after 'wax:iiif'".magenta if args.empty?
    Iiif.process(collections_by_name)
  end
end
