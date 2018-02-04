require 'yaml'
require 'colorized_string'

namespace :wax do
  desc 'get _config.yaml and parse cmd line args'
  task :config do
    begin
      $config = YAML.load_file('_config.yml')
      $argv = ARGV.drop(1)
      $argv.each { |a| task a.to_sym }
    rescue StandardError
      abort 'Cannot load _config.yml'.magenta
    end
  end
end
