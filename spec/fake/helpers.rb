require 'csv'
require 'colorized_string'

# helper methods
def slug(str)
  str.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
end

def write_csv(path, hashes)
  CSV.open(path, 'wb:UTF-8') do |csv|
    csv << hashes.first.keys
    hashes.each do |hash|
      csv << hash.values
    end
  end
rescue StandardError
  abort "Cannot write csv data to #{path} for some reason.".magenta
end

def add_collections_to_config(argv, collection_data, config)
  collection_hash = {}
  argv.each do |coll_name|
    ext = collection_data[coll_name]['type']
    collection_hash[coll_name] = {
      'source' => coll_name + ext,
      'layout' => 'iiif-image-page',
      'keep_order' => true
    }
  end
  config['collections'] = collection_hash
  output = YAML.dump config
  File.write('_config.yml', output)
end

def add_lunr_data(config, collection_data)
  config['collections'].each do |collection|
    name = collection[0]
    lunr_hash = {
      'content' => false,
      'fields' => collection_data[name]['keys']
    }
    # add it to config
    config['collections'][name]['lunr_index'] = lunr_hash
    output = YAML.dump config
    File.write('_config.yml', output)
  end
end
