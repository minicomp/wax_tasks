require 'yaml'

require_relative 'wax_tasks/branch'
require_relative 'wax_tasks/collection'
require_relative 'wax_tasks/error'
require_relative 'wax_tasks/iiif_collection'
require_relative 'wax_tasks/lunr_collection'
require_relative 'wax_tasks/pagemaster_collection'
require_relative 'wax_tasks/utils'

# Main WaxTasks module
module WaxTasks
  CONFIG_FILE = YAML.load_file('./_config.yml')
  SITE_CONFIG = {
    title:            CONFIG_FILE.fetch('title', ''),
    url:              CONFIG_FILE.fetch('url', ''),
    baseurl:          CONFIG_FILE.fetch('baseurl', ''),
    source_dir:       CONFIG_FILE.fetch('source', false),
    collections_dir:  CONFIG_FILE.fetch('collections_dir', false),
    collections:      CONFIG_FILE.fetch('collections', false),
    js:               CONFIG_FILE.fetch('js', false),
    permalink:        WaxTasks::Utils.construct_permalink(CONFIG_FILE)
  }.freeze
end
