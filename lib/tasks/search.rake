# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'build lunr search index (with default UI if UI=true)'
  task :search do
    site = WaxTasks::Site.new
    WaxTasks.generate_search_index(site, !!ENV['UI'])
  end

  # alias lunr to search for backwards compatibility
  task :lunr => :search
end
