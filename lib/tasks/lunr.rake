require 'lunr_index'

namespace :wax do
  desc 'build lunr search index'
  task :lunr => :config do
    collections = $config['collections']
    lunr_language = $config['lunr_language']
    index = LunrIndex.new(collections, lunr_language)

    Dir.mkdir('js') unless File.exist?('js')
    File.open('js/lunr-index.js', 'w') { |file| file.write(index.output) }
    puts "Writing lunr index to js/lunr-index.js".cyan
  end
end
