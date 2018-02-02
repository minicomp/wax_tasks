$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'wax_tasks'
  s.version       = '0.0.25'
  s.authors       = ['Marii Nyrop']
  s.email         = ['m.nyrop@columbia.edu']
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/mnyrop/wax_tasks'
  s.summary       = 'Rake tasks for minimal exhibitions.'
  s.description   = 'Rake tasks for minimal iiif exhibition sites with Jekyll.'

  s.files = Dir['Gemfile', 'lib/**/*']
  s.test_files    = ['spec/*']
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '>= 1.15'
  s.add_development_dependency 'faker', '>= 1.8.7'
  s.add_development_dependency 'rspec', '>= 3.5'
  s.add_development_dependency 'rubocop', '>= 0.52'

  s.add_runtime_dependency 'colorize', '>= 0.8'
  s.add_runtime_dependency 'html-proofer', '>= 3.0'
  s.add_runtime_dependency 'iiif_s3', '>= 0.1'
  s.add_runtime_dependency 'jekyll', '>= 3.5'
  s.add_runtime_dependency 'rake', '>= 12.0'
end
