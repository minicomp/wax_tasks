require_relative 'modules/iiif'
require_relative 'modules/lunr'
require_relative 'modules/pagemaster'

require 'yaml'
require 'wax_iiif'

# umbrella module for registering task modules
module WaxTasks
  def self.pagemaster(name, site_config)
    collection_config = Pagemaster.valid_config(name, site_config)

    src     = collection_config['source']
    data    = Pagemaster.ingest(src)
    layout  = collection_config.fetch('layout').to_s
    perma   = config['permalink'] == 'pretty' ? '/' : '.html'
    cdir    = site_config['collections_dir'].to_s
    order   = collection_config.key?('keep_order') ? collection_config.fetch('keep_order') : false

    Pagemaster.generate_pages(data, name, layout, cdir, order, perma)
  end

  def self.lunr(site_config)
    cdir          = site_config['collections_dir'].to_s
    collections   = Lunr.collections(site_config)
    total_fields  = Lunr.total_fields(collections)

    index         = Lunr.index(cdir, collections)
    ui            = Lunr.ui(total_fields)

    Lunr.write_index(index)
    Lunr.write_ui(ui)
  end

  def self.iiif(args, site_config)
    Iiif.ingest_collections(args, site_config)
  end

  def self.config
    YAML.load_file('_config.yml')
  end

  def self.slug(str)
    str.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
  end
end
