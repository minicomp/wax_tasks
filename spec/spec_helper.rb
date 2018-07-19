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
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
  add_filter 'branch'
end

require 'faker'
require 'wax_tasks'
require_relative 'setup'

shared_context 'shared', :shared_context => :metadata do
  let(:task_runner) { WaxTasks::TaskRunner.new }
  let(:default_site) { task_runner.site }
  let(:args) { default_site[:collections].map{ |c| c[0] } }
  let(:index_path) { 'js/lunr_index.json' }
  let(:ui_path) { 'js/lunr_ui.js'}
end
