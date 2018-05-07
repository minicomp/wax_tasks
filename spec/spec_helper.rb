require 'simplecov'
SimpleCov.start

require_relative 'fake/data'
require_relative 'fake/site'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'wax_tasks'

silence_output do
  Fake.site
  Fake.data
end

site_config = WaxTasks.site_config
bad_src_config = {
  'collections' => {
    'test' => {
      'source' => 'test.jpg'
    }
  }
}
missing_src_config = {
  'collections' => {
    'test' => {
      'source' => 'test.csv'
    }
  }
}

describe 'wax:pagemaster' do
  args = site_config['collections'].map { |c| c[0] }
  args.each do |collection_name|
    silence_output { WaxTasks.pagemaster(collection_name, site_config) }
  end
  it 'generates pages to the correct directories' do
    args.each do |a|
      dir = Pagemaster.target_dir(a, site_config)
      pages = Dir.glob("#{dir}/*.md")
      expect(pages.length).to be > 0
      Fake.content(pages)
    end
  end
  context 'when given a collection arg not in config' do
    collection_name = 'not_a_collection'
    it 'throws a configuration error' do
      expect { silence_output { WaxTasks.pagemaster(collection_name, site_config) } }.to raise_error(SystemExit)
    end
  end
  context 'when given config with bad source' do
    collection_name = bad_src_config['collections'].first[0]
    it 'throws ingest error' do
      expect { silence_output { WaxTasks.pagemaster(collection_name, bad_src_config) } }.to raise_error(SystemExit)
    end
  end
  context 'when given config with missing source' do
    collection_name = missing_src_config['collections'].first[0]
    it 'throws io error' do
      expect { silence_output { WaxTasks.pagemaster(collection_name, missing_src_config) } }.to raise_error(SystemExit)
    end
  end
  context 'when trying to genrate pages that already exist' do
    it 'skips them' do
      expect { WaxTasks.pagemaster(args.first, site_config) }.to output(/.*Skipping.*/).to_stdout
    end
  end
end

describe 'wax:lunr' do
  silence_output { WaxTasks.lunr(site_config) }
  it 'generates a lunr index' do
    index = File.open('./js/lunr-index.json', 'r').read
    expect(index.length).to be > 1000
  end
  it 'generates a lunr ui' do
    ui = File.open('./js/lunr-ui.js', 'r').read
    expect(ui.length).to be > 100
  end
  context 'when a ui already exists' do
    it 'skips over it' do
      expect { WaxTasks.lunr(site_config) }.to output(/.*Skipping.*/).to_stdout
    end
  end
end

describe 'wax:iiif' do
  collection_name = site_config['collections'].first[0]
  images = Dir.glob('./_data/iiif/*.jpg')
  iiif_src_dir = "./_data/iiif/#{collection_name}"

  FileUtils.mkdir_p(iiif_src_dir)
  images.each { |f| FileUtils.cp(File.expand_path(f), iiif_src_dir) }
  silence_output { WaxTasks.iiif(collection_name, site_config) }

  it 'generates collections' do
    expect(File.exist?("./iiif/#{collection_name}/collection/top.json")).to be true
  end
  it 'generates manifests' do
    expect(File.exist?("./iiif/#{collection_name}/1/manifest.json")).to be true
  end
  it 'generates derivatives' do
    expect(Dir.exist?("./iiif/#{collection_name}/images")).to be true
  end
  it 'generates image variants' do
    [250, 600, 1140].each do |size|
      expect(File.exist?("./iiif/#{collection_name}/images/1-1/full/#{size},/0/default.jpg")).to be true
    end
  end
  context 'when looking for a missing dir' do
    it 'throws an io error' do
      collection_name = 'not_a_collection'
      expect { silence_output { WaxTasks.iiif(collection_name, site_config) } }.to raise_error(SystemExit)
    end
  end
end

describe 'jekyll' do
  it 'builds successfully' do
    silence_output { Bundler.with_clean_env { system('bundle exec jekyll build') } }
  end
end

describe 'wax:jspackage' do
  before(:all) do
    silence_output { system('bundle exec rake wax:jspackage') }
  end
  it 'writes a package.json file' do
    package = File.open('package.json', 'r').read
    expect(package.length > 90)
  end
end

describe 'wax:test' do
  it 'passes html-proofer' do
    silence_output { system('bundle exec rake wax:test') }
  end
end
