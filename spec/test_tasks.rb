require 'yaml'
require 'fileutils'
require 'fake/helpers'
require 'fake/site'
require 'fake/data'

# run + test wax:config
describe 'wax_tasks' do
  Fake.site
  collection_data = Fake.data
  config = YAML.load_file('_config.yml')
  argv = collection_data.map { |col| col[0] }
  add_collections_to_config(argv, collection_data, config)
  add_lunr_data(config, collection_data)

  it 'accesses _config.yml and argv' do
    expect(config.length)
    expect(argv.length)
  end

  it 'generates pages' do
    system("bundle exec rake wax:pagemaster #{argv.join(' ')}")
    argv.each { |a| expect(Dir.exist?('_' + a)) }
  end

  it 'generates a lunr index' do
    system("bundle exec rake wax:lunr")
    index = File.open('js/lunr-index.json', 'r').read
    ui = File.open('js/lunr-ui.js', 'r').read
    expect(index.length > 1000)
    expect(ui.length > 100)
  end

  it 'generates iiif tiles and data' do
    images = Dir.glob('./_data/iiif/*.jpg')
    collection_data.each do |coll|
      new_dir = './_data/iiif/' + coll[0]
      mkdir_p(new_dir)
      images.each { |f| cp(File.expand_path(f), new_dir) }
    end
    rm_r(images)
    system("bundle exec rake wax:iiif #{argv.first}")
  end
end
