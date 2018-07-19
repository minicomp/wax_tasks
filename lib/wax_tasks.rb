require 'colorize'
require 'csv'
require 'json'
require 'yaml'

require_relative 'wax_tasks/branch'
require_relative 'wax_tasks/collection'
require_relative 'wax_tasks/error'
require_relative 'wax_tasks/iiif_collection'
require_relative 'wax_tasks/lunr_collection'
require_relative 'wax_tasks/lunr_index'
require_relative 'wax_tasks/pagemaster_collection'
require_relative 'wax_tasks/task_runner'
require_relative 'wax_tasks/utils'

# Main WaxTasks module
module WaxTasks
  # ---------
  # Constants
  # ---------

  # Path to load Jekyll site config
  DEFAULT_CONFIG  = '_config.yml'.freeze

  # Path to write WaxTasks::LunrIndex
  LUNR_INDEX_PATH = 'js/lunr_index.json'.freeze

  # Path to write default LunrUI
  LUNR_UI_PATH    = 'js/lunr_ui.js'.freeze
end
