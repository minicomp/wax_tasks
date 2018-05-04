# require_relative 'wax_tasks/iiif'
# require_relative 'wax_tasks/lunr'
# require_relative 'wax_tasks/pagemaster'
#
# require 'wax_iiif'
require 'yaml'

# umbrella module for registering task modules
module WaxTasks

  def self.site_config
    YAML.load_file('_config.yml')
  end

  def self.permalink_style(site_config)
    site_config['permalink'] == 'pretty' ? '/' : '.html'
  end

  def self.collections_dir(site_config)
    site_config['collections_dir'].to_s
  end

  def self.collections_config(site_config)
    site_config['collections']
  end

  def self.pagemaster(collection)
    puts "pagemaster #{collection}"
  end

  def self.pagemaster(collection)
    puts "pagemaster #{collection}"
  end

  class Collection
    def initialize(opts)
      @name             = opts.fetch(:name)
      @source           = opts.fetch(:source)
      @layout           = opts.fetch(:layout)
      @permalink_style  = opts.fetch(:permalink)
      @collections_dir  = opts.fetch(:collections_dir)
      @keep_order       = opts.fetch(:keep_order)
      @iiif_src         = "_data/iiif/#{@name}"
    end
  end

  class Index
    def initialize(opts)

    end
  end

end

  # def self.lunr(site_config)
  #   cdir          = site_config['collections_dir'].to_s
  #   collections   = Lunr.collections(site_config)
  #   total_fields  = Lunr.total_fields(collections)
  #   index         = Lunr.index(cdir, collections)
  #   ui            = Lunr.ui(total_fields)
  #
  #   Lunr.write_index(index)
  #   Lunr.write_ui(ui)
  # end
  #
  # def self.pagemaster(name, site_config)
  #   conf    = Pagemaster.valid_config(name, site_config)
  #   data    = Pagemaster.ingest(conf['source'])
  #   layout  = conf.fetch('layout').to_s
  #   perma   = site_config['permalink'] == 'pretty' ? '/' : '.html'
  #   cdir    = site_config['collections_dir'].to_s
  #   order   = conf.key?('keep_order') ? conf['keep_order'] : false
  #
  #   Pagemaster.generate_pages(data, name, layout, cdir, order, perma)
  # end
  #
  # def self.iiif(args, site_config)
  #   Iiif.ingest_collections(args, site_config)
  # end
  #
  # def self.slug(str)
  #   str.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
  # end

site_config = WaxTasks.site_config
permalink_style = WaxTasks.permalink_style(site_config)
collections_config = WaxTasks.collections_config(site_config)

puts collections_config

# collection_config = site_config['collections'][arg]
#
#
# opts = {
#   name: 'archive',
#   source:'archive.csv',
#   layout: 'image-page',
#   keep_order: site_config.key? ('keep_order') ? false : site_config['keep_order']
#   permalink_style: permalink_style,
#   collections_dir: collections_dir
# }
#
# collection = WaxTasks::Collection.new(opts)
# collections = []
# collections << collection
#
# WaxTasks.pagemaster(collection)
# WaxTasks.iiif(collection)
# WaxTasks.lunr(collections)
