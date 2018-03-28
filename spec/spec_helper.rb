require 'fileutils'

require_relative 'fake/data'
require_relative 'fake/site'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'wax_tasks'

Fake.site
Fake.data

describe 'wax:pagemaster' do
  config = WaxTasks.config
  args = config['collections'].map{ |c| c[0]}
  system("bundle exec rake wax:pagemaster #{args.join(' ')} > /dev/null")
  it 'generates directories' do
    args.each { |a| expect(Dir.exist?('_' + a)) }
  end
  it 'generates pages' do
    args.each { |a| expect(Dir.glob("_#{a}/*.md")) }
  end
end

describe 'wax:lunr' do
  system("bundle exec rake wax:lunr > /dev/null")
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
  args = site_config['collections'].map{ |c| c[0]}

  it 'generates iiif tiles and data' do
    images = Dir.glob('./_data/iiif/*.jpg')
    site_config['collections'].each do |c|
      new_dir = './_data/iiif/' + c[0]
      mkdir_p(new_dir)
      images.each { |f| cp(File.expand_path(f), new_dir) }
    end
    rm_r(images)
    system("bundle exec rake wax:iiif #{args.first} > /dev/null")
    args.each { |a| expect(Dir.exist?('iiif/images' + a)) }
  end
end

describe 'jekyll' do
  it 'builds successfully' do
    Bundler.with_clean_env do system("bundle exec jekyll build > /dev/null") end
  end
end

describe "wax:jspackage" do
  system("bundle exec rake wax:jspackage > /dev/null")
  it 'writes a package.json file' do
    package = File.open('package.json', 'r').read
    expect(package.length > 90)
  end
end

describe "wax:test" do
  it 'passes html-proofer' do system("bundle exec rake wax:test > /dev/null") end
end
