require_relative 'wax_tasks/branch'
require_relative 'wax_tasks/collection'
require_relative 'wax_tasks/error'
require_relative 'wax_tasks/iiif_collection'
require_relative 'wax_tasks/local_branch'
require_relative 'wax_tasks/lunr_collection'
require_relative 'wax_tasks/lunr_index'
require_relative 'wax_tasks/pagemaster_collection'
require_relative 'wax_tasks/task_runner'
require_relative 'wax_tasks/travis_branch'
require_relative 'wax_tasks/utils'

# The WaxTasks module powers the Rake tasks in `./tasks`, including:
#
# wax:pagemaster  :: generate collection md pages from csv, json, or yaml file
# wax:lunr        :: build lunr search index (with default UI if UI=true)
# wax:iiif        :: generate iiif derivatives from local image files
# wax:jspackage   :: write a simple package.json for monitoring js dependencies
# wax:push        :: push compiled Jekyll site to git branch
# wax:test        :: run htmlproofer, rspec if .rspec file exists
#
# Tasks are run by a WaxTasks::TaskRunner object which is resposible
# for reading in site config from `_config.yml`
module WaxTasks
  # ----------
  # CONSTANTS
  # ----------

  # @return [String] The path to load Jekyll site config
  DEFAULT_CONFIG  = '_config.yml'.freeze
  # @return [String] The path to write WaxTasks::LunrIndex
  LUNR_INDEX_PATH = 'js/lunr_index.json'.freeze
  # @return [String] The path to write default LunrUI
  LUNR_UI_PATH    = 'js/lunr_ui.js'.freeze
  # @return [String] The path to the compiled Jekyll site
  SITE_DIR        = './_site'.freeze
end
