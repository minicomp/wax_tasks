$LOAD_PATH.push File.expand_path('../lib')

Gem::Specification.new do |s|
  s.name          = 'wax_tasks'
  s.version       = '1.0.0-beta'
  s.authors       = ['Marii Nyrop']
  s.email         = ['m.nyrop@columbia.edu']
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/minicomp/wax_tasks'
  s.summary       = 'Rake tasks for minimal exhibition sites with Jekyll Wax.'
  s.description   = 'Rake tasks for minimal exhibition sites with Jekyll Wax.'

  s.files = Dir['Gemfile', 'lib/**/*']
  s.test_files    = Dir['spec/*']
  s.require_paths = ['lib']

  s.requirements << 'imagemagick'
  s.requirements << 'ghostscript'

  s.add_dependency 'html-proofer', '~> 3.9'
  s.add_dependency 'jekyll', '~> 3.8'
  s.add_dependency 'rake', '~> 12.3'
  s.add_dependency 'wax_iiif', '~> 0.1.0'

  s.add_development_dependency 'bundler', '~> 1'
  s.add_development_dependency 'rspec', '~> 3'
end
