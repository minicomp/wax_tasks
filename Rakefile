begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'bundler/gem_tasks'

# Add our gem's rake task files
Dir.glob("lib/tasks/*.rake").each do |rakefile|
  load rakefile
end
