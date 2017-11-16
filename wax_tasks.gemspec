$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "wax_tasks"
  s.version     = "0.0.1"
  s.authors     = ["marii nyröp"]
  s.email       = ["m.nyrop@columbia.edu"]
  s.homepage    = "https://github.com/mnyrop/wax_tasks"
  s.summary     = "Rake tasks for DH Static Sites."
  s.description = "Rake tasks for DH Static Sites, as part of the Jekyll-Wax project."

  s.files = Dir['README*', 'Gemfile', 'lib/**/*']

  s.add_dependency "rake", "~> 12.2"
  s.add_dependency "tqdm", "~> 0.3.0"
end
