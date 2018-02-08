require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster => :config do
    if $argv.empty?
      puts "You must specify one or more collections after 'bundle exec rake wax:pagemaster' to generate.".magenta
      exit 1
    else
      $argv.each do |collection_name|
        collection_config = valid_pagemaster(collection_name)
        collections_dir   = $config['collections_dir'].nil? ? '' : $config['collections_dir'].to_s + '/'
        collection = Collection.new(collection_name, collection_config, collections_dir)
        collection.pagemaster
      end
    end
  end
end
