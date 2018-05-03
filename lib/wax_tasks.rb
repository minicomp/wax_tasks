require_relative 'modules/iiif'
require_relative 'modules/lunr'
require_relative 'modules/pagemaster'

require 'wax_iiif'
require 'yaml'

# umbrella module for registering task modules
module WaxTasks
  def self.pagemaster(name, site_config)
    conf    = Pagemaster.valid_config(name, site_config)
    data    = Pagemaster.ingest(conf['source'])
    layout  = conf.fetch('layout').to_s
    perma   = site_config['permalink'] == 'pretty' ? '/' : '.html'
    cdir    = site_config['collections_dir'].to_s
    order   = conf.key?('keep_order') ? conf['keep_order'] : false

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
