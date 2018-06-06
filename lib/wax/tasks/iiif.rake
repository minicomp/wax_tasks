require 'wax_tasks'

namespace :wax do
  task :iiif do
    ARGS = ARGV.drop(1).each { |a| task a.to_sym }
    abort "You must specify a collection after 'wax:iiif'" if ARGS.empty?
    ARGS.each { |name| IiifCollection.new(name).process }
  end
end
