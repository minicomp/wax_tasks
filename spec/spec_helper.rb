require 'simplecov'

SimpleCov.start

require_relative 'fake/data'
require_relative 'fake/site'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'wax_tasks'

Fake.site
Fake.data

describe 'wax:pagemaster' do
  site_config = WaxTasks.config
  args = site_config['collections'].map { |c| c[0] }
  args.each { |a| WaxTasks.pagemaster(a, site_config) }
  it 'generates directories' do
    args.each { |a| expect(Dir.exist?('_' + a)) }
  end
  it 'generates pages' do
    args.each { |a| expect(Dir.glob("_#{a}/*.md")) }
  end
end

describe 'wax:lunr' do
  site_config = WaxTasks.config
  WaxTasks.lunr(site_config)
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
  site_config = WaxTasks.config
  args = site_config['collections'].map { |c| c[0] }

  it 'generates iiif tiles and data' do
    images = Dir.glob('./_data/iiif/*.jpg')
    site_config['collections'].each do |c|
      new_dir = './_data/iiif/' + c[0]
      FileUtils.mkdir_p(new_dir)
      images.each { |f| FileUtils.cp(File.expand_path(f), new_dir) }
    end
    FileUtils.rm_r(images)
    WaxTasks.iiif(args, site_config)
    args.each { |a| expect(Dir.exist?('iiif/images' + a)) }
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
