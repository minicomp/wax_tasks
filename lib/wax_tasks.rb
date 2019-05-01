# frozen_string_literal: true

# rubygems
require 'rubygems'

# stdlib
require 'csv'
require 'fileutils'
require 'json'
require 'yaml'

# 3rd party
require 'html-proofer'
require 'mini_magick'
require 'wax_iiif'
require 'safe_yaml/load'

# relative
require_relative 'wax_tasks/collection'
require_relative 'wax_tasks/error'
require_relative 'wax_tasks/index'
require_relative 'wax_tasks/site'
require_relative 'wax_tasks/utils'

#
module WaxTasks
  # @return [String] The path to load Jekyll site config
  DEFAULT_CONFIG          = '_config.yml'

  # @return [String] The path to the compiled Jekyll site
  SITE_DIR                = '_site'

  #
  #
  #
  def self.generate_pages(collection)
    metadata = collection.metadata
    page_dir = collection.page_dir
    skipped  = 0
    FileUtils.mkdir_p(page_dir)
    metadata.each_with_index do |item, idx|
      item['pid']       = Utils.slug(item.fetch('pid'))
      item['layout']    = collection.layout unless collection.layout.nil?
      item['order']     = Utils.padded_int(idx, metadata.length)
      path              = "#{page_dir}/#{item['pid']}.md"
      if File.exist?(path)
        skipped += 1
        puts "#{item['pid']}.md already exits. Skipping."
      else
        File.open(path, 'w') { |f| f.write("#{YAML.dump(item)}---") }
      end
    end
    puts "#{metadata.length - skipped} pages were generated to #{page_dir} directory.".cyan
  end

  #
  #
  #
  def self.generate_search(site)
    site.search.each do |c|
      config      = c[1]
      collections = config.dig('collections').keys.map do |name|
        WaxTasks::Collection.new(site, name)
      end

      raise WaxTasks::Error::NoSearchCollections unless collections&.first.is_a? Collection

      index = Index.new(config, collections)
      path  = Utils.safe_join(site.source, index.path)

      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.write(index.to_s) }

      puts "Generated search index to #{path}".cyan
    end
  end

  # def self.derivatives_simple(site, collection_name)
  #
  # end
  #
  # def self.derivatives_iiif(site, collection_name)
  #
  # end
end
