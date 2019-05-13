# run $ DEBUG=true bundle exec rspec for verbose output
# run $ bundle exec rspec for sparse output
QUIET = !ENV['DEBUG']

# use codecov + add requirements
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

# load + setup
require 'wax_tasks'
require 'setup'

# provide shared context for tests
shared_context 'shared', :shared_context => :metadata do
   let(:config_from_file) { WaxTasks.config_from_file("#{BUILD}/_config.yml") }
   let(:invalid_content_config) { WaxTasks.config_from_file("#{BUILD}/_invalid_content_config.yml") }
   let(:invalid_format_config) { WaxTasks.config_from_file("#{BUILD}/_invalid_format_config.yml") }
   let(:empty_config) { Hash.new }
   let(:args_from_file) { %w[csv_collection json_collection yaml_collection]}
end
