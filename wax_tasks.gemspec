$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "wax_tasks"
  s.version     = "1.0.1.pre"
  s.authors     = ["Marii Nyröp"]
  s.email       = ["m.nyrop@columbia.edu"]
  s.license     = "MIT"
  s.homepage    = "https://github.com/mnyrop/wax_tasks"
  s.summary     = "Rake tasks for minimal exhibitions."
  s.description = "Rake tasks for minimal exhibition sites with Jekyll. See: minicomp/wax."

  s.files = Dir['README*', 'Gemfile', 'lib/**/*']

  s.add_runtime_dependency "rake","~> 12"
  s.add_runtime_dependency "iiif_s3", "~> 0.1"
end
