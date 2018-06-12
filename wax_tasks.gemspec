$LOAD_PATH.push File.expand_path('../lib')

Gem::Specification.new do |s|
  s.name          = 'wax_tasks'
  s.version       = '0.2.0'
  s.authors       = ['Marii Nyrop']
  s.email         = ['m.nyrop@columbia.edu']
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/minicomp/wax_tasks'
  s.summary       = 'Rake tasks for minimal exhibitions.'
  s.description   = 'Rake tasks for minimal iiif exhibition sites with Jekyll.'

  s.files = Dir['Gemfile', 'lib/**/*']
  s.test_files    = Dir['spec/*']
  s.require_paths = ['lib']
  s.requirements << 'imagemagick'

  s.add_dependency 'colorize', '~> 0.8'
  s.add_dependency 'html-proofer', '~> 3'
  s.add_dependency 'jekyll', '~> 3'
  s.add_dependency 'rake', '~> 12'
  s.add_dependency 'wax_iiif', '~> 0.0.2'

  s.add_development_dependency 'bundler', '~> 1'
  s.add_development_dependency 'faker', '~> 1'
  s.add_development_dependency 'rspec', '~> 3'
end
