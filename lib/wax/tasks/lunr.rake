require 'wax_tasks'
require 'optparse'

namespace :wax do
  desc 'build lunr search index (with default UI if UI=true)'
  task :lunr do
    idx = Index.new # make + write index
    UI.new(idx) if ENV['UI'] # if --ui option is true, make and write ui
  end
end
