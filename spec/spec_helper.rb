# run $ DEBUG=true bundle exec rspec for verbose output
# run $ bundle exec rspec for sparse output
QUIET = !ENV['DEBUG']

# use codecov + add requirements
require 'setup'
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end
require 'wax_tasks'

# provide shared context for tests
shared_context 'shared', :shared_context => :metadata do
   let(:config_from_file)         { WaxTasks.config_from_file }
   let(:invalid_content_config)   { WaxTasks.config_from_file("#{BUILD}/_invalid_content_config.yml") }
   let(:invalid_format_config)    { WaxTasks.config_from_file("#{BUILD}/_invalid_format_config.yml") }
   let(:empty_config)             { Hash.new }

   let(:site_from_config_file)    { WaxTasks::Site.new(config_from_file) }
   let(:site_from_empty_config)   { WaxTasks::Site.new(empty_config) }
   let(:site_from_invalid_config) { WaxTasks::Site.new(invalid_content_config) }

   let(:args_from_file)           { %w[csv_collection json_collection yaml_collection] }
   let(:csv)                      { args_from_file.first }
   let(:json)                     { args_from_file[1] }
   let(:yaml)                     { args_from_file[2] }
end
