# toggle stdout/stderr verbosity
#
# run $ DEBUG=true bundle exec rspec for verbose output
# run $ bundle exec rspec for sparse output
case ENV['DEBUG']
when 'true' then QUIET = false
else QUIET = true
end

# use codecov + add requirements
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_filter 'branch'
end

# load + setup
require 'wax_tasks'
require 'setup'

# provide shared context for tests
shared_context 'shared', :shared_context => :metadata do
  let(:task_runner) { WaxTasks::TaskRunner.new }
  let(:default_site) { task_runner.site }
  let(:args) { default_site[:collections].map{ |c| c[0] } }
  let(:index_path) { 'js/lunr_index.json' }
  let(:ui_path) { 'js/lunr_ui.js'}
end

# run tests in a more intuitive order
require 'tests/tasks_spec'
require 'tests/task_runner_spec'
require 'tests/utils_spec'
require 'tests/pagemaster_collection_spec'
require 'tests/lunr_collection_spec'
require 'tests/iiif_collection_spec'
require 'tests/branch_spec'
