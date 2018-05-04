require 'yaml'

require_relative 'modules/iiif'
require_relative 'modules/lunr'
require_relative 'modules/pagemaster'

# umbrella module for registering task modules
module WaxTasks
  # include ActiveModel::Validations

  class Collection
    attr_reader :name, :source, :layout, :keep_order, :lunr_index

    def initialize(opts)
      @name             = opts.fetch(:name)
      @source           = opts.fetch(:source)
      @layout           = opts.fetch(:layout)
      @keep_order       = opts.fetch(:keep_order)
      @lunr_index       = opts.fetch(:lunr_index)
    end
  end

  def self.site_config
    YAML.load_file('_config.yml')
  end

  def self.permalink_style(site_config)
    site_config['permalink'] == 'pretty' ? '/' : '.html'
  end

  def self.collection_config(name)
    collection = site_config.fetch('collections').fetch(name)
    opts = {
      name: name,
      source: collection['source'],
      layout: collection['layout'],
      keep_order: collection.key?('keep_order') ? false : collection['keep_order'],
      lunr_index: collection['lunr_index']
    }
    opts
  rescue => e
    abort "Collection #{name} is not properly configured.".magenta + "\n#{e}"
  end

  def self.slug(str)
    str.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
  end
end
