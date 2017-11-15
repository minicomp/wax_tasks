begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'bundler/gem_tasks'

puts hello

puts "Gem::Specification.find_by_name 'wax_tasks'"
spec = Gem::Specification.find_by_name 'wax_tasks'
puts spec
Dir.glob("#{spec.gem_dir}/lib/tasks/*.rake").each {|r| puts r}
