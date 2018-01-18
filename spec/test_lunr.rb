require 'rake'
require 'yaml'
require 'csv'

describe 'wax:lunr' do
  it 'generates a lunr index' do
    lunr_hash = { 'content' => false, 'multi-language' => true, 'meta' => [] }
    $config['collections'].each do |c|
      name = c[0]
      fields = CSV.read('_data/' + name + '.csv', :headers => true).headers
      meta_hash = { 'dir' => name, 'fields' => fields }
      lunr_hash['meta'] << meta_hash
    end
    $config['lunr'] = lunr_hash
    output = YAML.dump $config
    File.write('_config.yml', output)
    load File.expand_path("../../lib/tasks/lunr.rake", __FILE__)
    Rake::Task['wax:lunr'].invoke
    index = File.open('js/lunr-index.js', 'r').read
    expect(index.length > 1000)
  end
end
