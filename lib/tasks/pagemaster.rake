require 'colorized_string'
require 'wax_collection'
require 'helpers'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster => :config do
    if $argv.empty?
      puts "You must specify one or more collections after 'bundle exec rake wax:pagemaster' to generate.".magenta
      exit 1
    else
      $argv.each do |collection_name|
        collection_config = valid_pagemaster(collection_name)
        collection = WaxCollection.new(collection_name, collection_config)
        collection.pagemaster
      end
    end
  end
end
