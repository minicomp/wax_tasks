require 'wax_tasks'

namespace :wax do
  task :iiif do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    abort "You must specify a collection after 'wax:iiif'" if args.empty?
    args.each { |a| IiifCollection.new(a).process }
  end
end
