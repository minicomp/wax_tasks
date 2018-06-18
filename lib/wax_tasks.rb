require 'yaml'

require_relative 'wax/branch'
require_relative 'wax/collection'
require_relative 'wax/index'
require_relative 'wax/iiif_collection'
require_relative 'wax/lunr_collection'
require_relative 'wax/pagemaster_collection'
require_relative 'wax/utilities'

# Main WaxTasks module
module WaxTasks
  # accesses Jekyll site config `_config.yml`
  # returns a hashmap of relevant site wide info
  def self.site_config
    site_config = YAML.load_file('./_config.yml')
    s_conf = {
      title:       site_config.fetch('title', ''),
      url:         site_config.fetch('url', ''),
      baseurl:     site_config.fetch('baseurl', ''),
      permalink:   site_config.fetch('permalink', false),
      c_dir:       site_config.fetch('collections_dir', false),
      collections: site_config.fetch('collections', false),
      js:          site_config.fetch('js', false)
    }
    s_conf[:permalink] = s_conf[:permalink] == 'pretty' ? '/' : '.html'
    s_conf
  end

  include Branch
  include Utils
  include Message
  include Error
end
