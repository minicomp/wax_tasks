require 'wax_tasks'

namespace :wax do
  desc 'build lunr search index'
  task :lunr do
    site_config = WaxTasks.site_config
    WaxTasks.lunr(site_config)
  end
end
