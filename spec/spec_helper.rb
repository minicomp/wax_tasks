# toggle stdout/stderr verbosity
QUIET = true

# use codecov + add requirements
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_filter 'utilities'
  add_filter 'branch'
end

require_relative './../lib/wax_tasks'
require_relative 'fake/site'

# setup
quiet_stdout { Fake.site }

# constants
SITE_CONFIG = WaxTasks.site_config
ARGS = SITE_CONFIG[:collections].map { |c| c[0] }
PM_COLLECTIONS = quiet_stdout { ARGS.map { |a| PagemasterCollection.new(a) } }
IIIF_COLLECTIONS = ARGS.map { |a| IiifCollection.new(a) }

# run specs
require_relative 'pagemaster'
require_relative 'lunr'
require_relative 'iiif'

describe 'jekyll' do
  it 'builds successfully' do
    quiet_stdout { Bundler.with_clean_env { system('bundle exec jekyll build') } }
  end
end

describe 'wax:jspackage' do
  it 'writes a package.json file' do
    quiet_stdout { system('bundle exec rake wax:jspackage') }
    package = File.open('package.json', 'r').read
    expect(package.length > 90)
  end
end

describe 'wax:test' do
  it 'passes html-proofer' do
    quiet_stdout { system('bundle exec rake wax:test') }
  end
end
