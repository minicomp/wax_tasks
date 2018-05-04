require 'colorized_string'
require 'wax_tasks'

namespace :wax do
  desc 'build lunr search index'
  task :lunr do
    site_config = WaxTasks.site_config
    idx = Lunr.index(site_config)
    ui = Lunr.ui(site_config)
    Lunr.write_index(idx)
    Lunr.write_ui(ui)
  end
end
