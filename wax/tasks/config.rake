require 'yaml'

namespace :wax do
  task :config do
    @config = YAML.load_file('_config.yml')
    @argv = ARGV.drop(1)
    @argv.each { |a| task a.to_sym do ; end }
  end
end
