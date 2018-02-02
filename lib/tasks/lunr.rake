require 'lunr_index'

namespace :wax do
  desc 'build lunr search index'
  task :lunr => :config do
    collections = $config['collections']
    lunr_language = $config['lunr_language']
    lunr_collections = []
    total_fields = []
    # register fields + lunr_collections
    collections.each do |c|
      if c[1].key?('lunr_index') && c[1]['lunr_index'].key?('fields')
        total_fields.concat c[1]['lunr_index']['fields']
        total_fields << 'content' if c[1]['lunr_index']['content']
        lunr_collections << c
      end
    end
    total_fields = total_fields.uniq
    # make index
    index = LunrIndex.new(lunr_collections, total_fields, lunr_language)
    index.process
    index.write_to_file
  end
end
