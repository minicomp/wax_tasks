require 'yaml'

require_relative 'modules/iiif'
require_relative 'modules/lunr'
require_relative 'modules/pagemaster'

# umbrella module for registering task modules
module WaxTasks
  def self.pagemaster(collection_name, site_config)
    collection = collection(collection_name, site_config)
    Pagemaster.generate(collection, site_config)
  end

  def self.lunr(site_config)
    Lunr.write_index(site_config)
    Lunr.write_ui(site_config)
  end

  def self.iiif(collection_name, site_config)
    Iiif.process(collection_name, site_config)
  end

  def self.site_config
    YAML.load_file('_config.yml')
  end

  def self.permalink_style(site_config)
    site_config['permalink'] == 'pretty' ? '/' : '.html'
  end

  def self.collection(collection_name, site_config)
    conf = site_config.fetch('collections').fetch(collection_name)
    {
      name: collection_name,
      source: conf['source'],
      layout: conf['layout'],
      keep_order: conf.key?('keep_order') ? conf['keep_order'] : false,
      lunr_index: conf['lunr_index']
    }
  rescue StandardError => e
    abort "Collection '#{collection_name}' is not properly configured.".magenta + "\n#{e}"
  end

  def self.slug(str)
    str.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
  end

  def self.ingest(source)
    src = "_data/#{source}"
    opts = { headers: true, encoding: 'utf-8' }

    case File.extname(src)
    when '.csv' then metadata = CSV.read(src, opts).map(&:to_hash)
    when '.json' then metadata = JSON.parse(File.read(src))
    when '.yml' then metadata = YAML.load_file(src)
    else abort "Source #{src} must be .csv, .json, or .yml.".magenta
    end

    puts "Processing #{src}...."
    validate(metadata)
  rescue StandardError => e
    abort "Cannot load #{src}. check for typos and rebuild.".magenta + "\n#{e}"
  end

  def self.validate(data)
    pids = data.map { |d| d['pid'] }
    duplicates = pids.detect { |p| pids.count(p) > 1 } || []
    abort "Fix duplicate pids: \n#{duplicates}".magenta unless duplicates.empty?
    data
  end
end
