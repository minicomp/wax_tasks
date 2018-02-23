require 'rake'

describe 'wax:lunr' do
  it 'generates a lunr index' do
    $config['collections'].each do |collection|
      name = collection[0]
      # get info on what to index
      lunr_hash = {
        'content' => false,
        'fields' => $collection_data[name]['keys']
      }
      # add it to config
      $config['collections'][name]['lunr_index'] = lunr_hash
      output = YAML.dump $config
      File.write('_config.yml', output)
    end
    # invoke lunr task
    load File.expand_path("../../../lib/tasks/lunr.rake", __FILE__)
    Rake::Task['wax:lunr'].invoke
    # expect a populated index
    index = File.open('js/lunr-index.json', 'r').read
    expect(index.length > 1000)
    ui = File.open('js/lunr-ui.js', 'r').read
    expect(ui.length > 100)
  end
end
