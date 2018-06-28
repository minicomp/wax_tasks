require 'yaml'

require_relative 'wax/branch'
require_relative 'wax/collection'
require_relative 'wax/iiif'
require_relative 'wax/lunr'
require_relative 'wax/pagemaster'
require_relative 'wax/utils'

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
    permalink:        Utils.construct_permalink
  }.freeze
end
