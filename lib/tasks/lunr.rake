require 'wax_tasks'

namespace :wax do
  desc 'build lunr search index'
  task :lunr => :config do
    Dir.mkdir('js') unless File.exist?('js')
    yaml = "---\nlayout: none\n---\n"
    lunr = Lunr.new($config)

    # write index to json file
    idx = yaml + lunr.index
    idx_path = 'js/lunr-index.json'
    File.open(idx_path, 'w') { |file| file.write(idx) }
    puts "Writing lunr index to #{idx_path}".cyan

    # write index.ui to js file
    ui = yaml + lunr.ui
    ui_path = 'js/lunr-ui.js'
    if File.exist?(ui_path)
      puts "Lunr UI already exists at #{ui_path}. Skipping".cyan
    else
      File.open(ui_path, 'w') { |file| file.write(ui) }
      puts "Writing lunr index to #{ui_path}".cyan
    end
  end
end
