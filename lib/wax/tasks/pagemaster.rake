require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    abort "You must specify a collection after 'wax:pagemaster'" if args.empty?
    args.each { |a| PagemasterCollection.new(a).generate_pages }
  end
end
