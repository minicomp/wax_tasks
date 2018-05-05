require 'simplecov'
require 'faker'

SimpleCov.start

require_relative 'fake/data'
require_relative 'fake/site'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'wax_tasks'

Fake.site
Fake.data

site_config = WaxTasks.site_config
bad_config = {
  'collections_dir' => '',
  'collections' => {
    'test' => {
      'source' => 'test.jpg'
    }
  }
}

describe 'wax:pagemaster' do
  args = site_config['collections'].map { |c| c[0] }
  args.each do |a|
    opts = WaxTasks.collection_config(a, site_config)
    collection = WaxTasks::Collection.new(opts)
    records = Pagemaster.ingest(collection.source)
    Pagemaster.generate(collection, records)
  end
  it 'generates directories' do
    args.each { |a| expect(Dir.exist?('_' + a)) }
  end
  it 'generates pages' do
    args.each do |a|
      pages = Dir.glob("_#{a}/*.md")
      expect(pages.length)
      pages.each do |page|
        File.open(page, 'a') { |f| f.puts "\n#{Faker::Markdown.random}\n" }
      end
    end
  end
  context 'when given a bad config' do
    arg = bad_config['collections'].map { |c| c[0] }.first
    opts = WaxTasks.collection_config(arg, bad_config)
    collection = WaxTasks::Collection.new(opts)
    it 'throws ingest error' do
      expect { Pagemaster.ingest(collection.source) }.to raise_error(SystemExit)
    end
  end
end

describe 'wax:lunr' do
  idx = Lunr.index(site_config)
  ui = Lunr.ui(site_config)
  Lunr.write_index(idx)
  Lunr.write_ui(ui)
  it 'generates a lunr index' do
    index = File.open('js/lunr-index.json', 'r').read
    expect(index.length > 1000)
  end

  it 'generates a lunr ui' do
    ui = File.open('js/lunr-ui.js', 'r').read
    expect(ui.length > 100)
  end
end

describe 'wax:iiif' do
  it 'generates iiif tiles and data' do
    names = site_config['collections'].map { |c| c[0] }
    images = Dir.glob('./_data/iiif/*.jpg')
    site_config['collections'].each do |c|
      new_dir = './_data/iiif/' + c[0]
      FileUtils.mkdir_p(new_dir)
      images.each { |f| FileUtils.cp(File.expand_path(f), new_dir) }
    end
    FileUtils.rm_r(images)
    Iiif.process([names.first])
    expect(Dir.exist?('iiif/images'))
  end
end

describe 'jekyll' do
  it 'builds successfully' do
    Bundler.with_clean_env { system('bundle exec jekyll build') }
  end
end

describe 'wax:jspackage' do
  system('bundle exec rake wax:jspackage')
  it 'writes a package.json file' do
    package = File.open('package.json', 'r').read
    expect(package.length > 90)
  end
end

describe 'wax:test' do
  it 'passes html-proofer' do system('bundle exec rake wax:test') end
end
