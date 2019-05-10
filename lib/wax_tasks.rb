# frozen_string_literal: true

# rubygems
require 'rubygems'

# stdlib
require 'csv'
require 'fileutils'
require 'json'
require 'yaml'

# 3rd party
require 'hashie'
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
require_relative 'wax_tasks/runner'
require_relative 'wax_tasks/utils'

#
module WaxTasks
  DEFAULT_CONFIG             = '_config.yml'
  ACCEPTED_IMAGE_FORMATS     = %w[.png .jpg .jpeg .tiff].freeze
  ACCEPTED_METADATA_FORMATS  = %w[.yml .yaml .csv .json].freeze
  DEFAULT_IMAGE_VARIANTS     = { thumbnail: 250, full: 1140 }.freeze
  IMAGE_DERIVATIVE_DIRECTORY = 'img/derivatives'
  DEFAULT_SEARCH_FIELDS      = %w[pid label thumbnail permalink].freeze
end
