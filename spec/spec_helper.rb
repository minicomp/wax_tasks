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

end
