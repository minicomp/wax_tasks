require 'yaml'
require 'colorized_string'

namespace :wax do
  desc 'get _config.yaml and parse cmd line args'
  task :config do
    abort('Please run this using `bundle exec rake`') unless ENV["BUNDLE_BIN_PATH"]
    begin
      $config = YAML.load_file('_config.yml')
      $argv = ARGV.drop(1)
      $argv.each { |a| task a.to_sym do ; end }
    rescue
      raise "Cannot load _config.yml".magenta
    end
  end
end
