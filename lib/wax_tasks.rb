# frozen_string_literal: true

# rubygems
require 'rubygems'

# stdlib
require 'csv'
require 'fileutils'
require 'json'
require 'yaml'

# 3rd party
require 'mini_magick'
require 'rainbow'
require 'safe_yaml/load'
require 'wax_iiif'


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
  DEFAULT_CONFIG             = '_config.yml'
  ACCEPTED_IMAGE_FORMATS     = %w[.png .jpg .jpeg .tiff].freeze
  DEFAULT_IMAGE_VARIANTS     = { thumbnail: 250, full: 1140 }.freeze
  IMAGE_DERIVATIVE_DIRECTORY = 'img/derivatives'
  DEFAULT_SEARCH_FIELDS      = %w[pid label thumbnail permalink].freeze

  #
  #
  #
  def self.generate_simple_derivatives(collection)
    result = collection.imagedata.map do |i|
      i.build_simple_derivatives
    end

    puts Rainbow("\nDone ✔").green
  end

  #
  #
  #
  def self.generate_iiif_derivatives(collection)
    collection.imagedata
  end
end
