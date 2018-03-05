require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    config = read_config
    argv = read_argv
    if argv.empty?
      puts "You must specify one or more collections after 'bundle exec rake wax:pagemaster' to generate.".magenta
      exit 1
    else
      argv.each do |name|
        collection = Collection.new(config, name)
        collection.pagemaster
      end
    end
  end
end
