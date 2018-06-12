require 'wax_tasks'

namespace :wax do
  desc 'build lunr search index'
  task :lunr do
    index = Index.new
    index.write
  end
end
