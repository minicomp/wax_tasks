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
require_relative 'wax_tasks/item'
require_relative 'wax_tasks/record'
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
    total      = 0
    metadata   = collection.metadata
    target_dir = collection.page_dir

    FileUtils.mkdir_p(target_dir)
    metadata.each_with_index do |record, i|
      record.order  = Utils.padded_int(i, metadata.length)
      record.layout = collection.layout unless collection.layout.nil?
      total += record.write_to_page(target_dir)
    end

    puts "\n#{total} pages were generated to #{target_dir}.\n#{collection.metadata.length - total} pages were skipped.".cyan
  end

  #
  #
  #
  def self.generate_static_search(site)
    site.search.each do |config|
      name = config[0]
      config = config[1]
      collections = config.dig('collections').keys.map do |n|
        WaxTasks::Collection.new(site, n)
      end

      raise WaxTasks::Error::NoSearchCollections unless collections&.first.is_a? Collection

      index = Index.new(config, collections)
      path  = Utils.safe_join(site.source, index.path)

      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.write(index.to_s) }

      puts "Generated #{name} search index to #{path}".cyan
    end
  end

  #
  #
  #
  def self.generate_simple_derivatives(collection)
    collection.imagedata
  end

  #
  #
  #
  def self.generate_iiif_derivatives(collection)
    collection.imagedata
  end
end
