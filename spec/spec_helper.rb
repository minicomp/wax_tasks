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
require 'faker'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
  add_filter 'branch'
end

# setup
%w(./build ./coverage).each { |d| FileUtils.rm_r(d) if File.directory?(d) }

require_relative 'fake/site'
require_relative './../lib/wax_tasks'
require_relative 'shared_context'

# run the specs
require_relative 'wax_tasks_spec'
require_relative 'pagemaster_spec'
require_relative 'utils_spec'
require_relative 'tasks_spec'
