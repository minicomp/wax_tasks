# run $ DEBUG=true bundle exec rspec for verbose output
# run $ bundle exec rspec for sparse output
QUIET = !ENV['DEBUG']

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
  let(:index_path) { "#{BUILD}/js/lunr-index.json" }
  let(:ui_path) { "#{BUILD }/js/lunr-ui.js" }
end
