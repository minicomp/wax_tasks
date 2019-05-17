# frozen_string_literal: true

# rubygems
require 'rubygems'

# stdlib
require 'csv'
require 'fileutils'
require 'json'
require 'tempfile'

# 3rd party
require 'rainbow'
require 'safe_yaml'

# relative
require_relative 'wax_tasks/asset'
require_relative 'wax_tasks/collection'
require_relative 'wax_tasks/config'
require_relative 'wax_tasks/error'
require_relative 'wax_tasks/index'
require_relative 'wax_tasks/item'
require_relative 'wax_tasks/record'
require_relative 'wax_tasks/site'
require_relative 'wax_tasks/utils'

#
module WaxTasks
  DEFAULT_CONFIG_FILE        = "#{Dir.pwd}/_config.yml"
  IMAGE_DERIVATIVE_DIRECTORY = 'img/derivatives'

  def self.config_from_file(file = nil)
    Utils.validate_yaml(file || DEFAULT_CONFIG)
  rescue StandardError => e
    raise WaxTasks::Error::InvalidConfig, "Cannot open config file '#{file}'.\n #{e}"
  end
end
