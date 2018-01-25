require 'rake'

describe 'wax:lunr' do
  it 'generates a lunr index' do
    # get info on what to index
    lunr_hash = { 'content' => false, 'multi-language' => true, 'meta' => [] }
    $collection_data.each { |coll| lunr_hash['meta'] << { 'dir' => coll[0], 'fields' => coll[1]['headers'] } }

    # add it to config
    $config['lunr'] = lunr_hash
    output = YAML.dump $config
    File.write('_config.yml', output)

    # invoke lunr task
    load File.expand_path("../../lib/tasks/lunr.rake", __FILE__)
    Rake::Task['wax:lunr'].invoke

    # expect a long index
    index = File.open('js/lunr-index.js', 'r').read
    expect(index.length > 1000)
  end
end
