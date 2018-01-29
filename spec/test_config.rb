require 'rake'
require 'yaml'

# run + test wax:config
describe 'wax:config' do
  it 'accesses _config.yml and argvs' do
    load File.expand_path("../../lib/tasks/config.rake", __FILE__)
    Rake::Task['wax:config'].invoke
    $collection_data.each { |col| $argv << col[0] }
    expect($config.length)
    expect($argv.length)

    # add collection data to config file
    collection_hash = {}
    $argv.each do |coll_name|
      ext = $collection_data[coll_name]['type']
      collection_hash[coll_name] = {
        'source'    => coll_name + ext,
        'directory' => coll_name,
        'layout'    => 'default'
      }
    end
    $config['collections'] = collection_hash
    output = YAML.dump $config
    File.write('_config.yml', output)
  end
end
