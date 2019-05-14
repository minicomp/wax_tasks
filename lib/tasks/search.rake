# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'build lunr search index (with default UI if UI=true)'
  task :search do
    config = WaxTasks::DEFAULT_CONFIG_FILE
    site = WaxTasks::Site.new(config)
    site.generate_static_search
  end

  # alias lunr to search for backwards compatibility
  task lunr: :search
end
