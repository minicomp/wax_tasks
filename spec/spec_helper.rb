#
# toggle stdout/stderr verbosity
# run with $ DEBUG=true bundle exec rspec
#
case ENV['DEBUG']
when 'true'
  QUIET = false
else
  QUIET = true
end

# use codecov + add requirements
require 'colorize'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
  add_filter 'utils'
  add_filter 'branch'
end

# setup
require_relative 'fake/site'
quiet_stdout { Fake.site }
require_relative './../lib/wax_tasks'

# shared contexts
shared_context 'shared', :shared_context => :metadata do
  quiet_stdout {
    # valid
    let(:valid_site_config) { WaxTasks::SITE_CONFIG }
    let(:valid_args) { valid_site_config[:collections].map { |c| c[0] } }
    let(:valid_pm_collections) { valid_args.map { |a| PagemasterCollection.new(a) } }
    let(:valid_iiif_collections) { valid_args.map { |a| IiifCollection.new(a) } }
    # invalid
    let(:invalid_collection) do
      PagemasterCollection.new(valid_args.first, { site_config: { 'bad' => nil } })
    end
    let(:missing_pid_collection) do
      c = PagemasterCollection.new(valid_args.first)
      c.data.first.delete('pid')
      c
    end
    let(:nonunique_pids) do
      nonunique_pids = PagemasterCollection.new(valid_args.first)
      nonunique_pids.data[3] = nonunique_pids.data.first.dup
      nonunique_pids
    end
  }
end

# run specs
require_relative 'pagemaster'
# require_relative 'lunr'
# require_relative 'iiif'
#
# describe 'jekyll' do
#   it 'builds successfully' do
#     quiet_stdout { Bundler.with_clean_env { system('bundle exec jekyll build') } }
#   end
# end
#
# describe 'wax:jspackage' do
#   it 'writes a package.json file' do
#     quiet_stdout { system('bundle exec rake wax:jspackage') }
#     package = File.open('package.json', 'r').read
#     expect(package.length > 90)
#   end
# end
#
# describe 'wax:test' do
#   it 'passes html-proofer' do
#     quiet_stdout { system('bundle exec rake wax:test') }
#   end
# end
