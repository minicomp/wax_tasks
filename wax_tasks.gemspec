$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'wax_tasks'
  s.version     = '0.0.1'
  s.authors     = ['Marii Nyröp']
  s.email       = ['m.nyrop@columbia.edu']
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/mnyrop/wax_tasks'
  s.summary     = 'Rake tasks for minimal exhibitions.'
  s.description = 'Rake tasks for minimal iiif exhibition sites with Jekyll.'

  s.files = Dir['README*', 'Gemfile', 'lib/**/*']

  s.add_runtime_dependency 'colorize', '~> 0.8'
  s.add_runtime_dependency 'html-proofer', '~> 3.0'
  s.add_runtime_dependency 'iiif_s3', '~> 0.1'
  s.add_runtime_dependency 'rake', '~> 12'
end
