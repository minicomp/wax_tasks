# frozen_string_literal: true

require_relative 'lib/wax_tasks/version'

Gem::Specification.new do |spec|
  spec.name          = 'wax_tasks'
  spec.version       = WaxTasks::VERSION
  spec.authors       = ['Marii Nyrop']
  spec.email         = ['marii@nyu.edu']
  spec.license       = 'MIT'
  spec.homepage      = 'https://github.com/minicomp/wax_tasks'
  spec.summary       = 'Rake tasks for minimal exhibition sites with Minicomp/Wax.'
  spec.description   = 'Rake tasks for minimal exhibition sites with Minicomp/Wax.'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.test_files             = Dir['spec/*']
  spec.required_ruby_version  = '>= 2.4'
  spec.metadata['yard.run']   = 'yri'

  spec.requirements << 'imagemagick'
  spec.requirements << 'ghostscript'

  spec.add_runtime_dependency 'progress_bar', '~> 1.3'
  spec.add_runtime_dependency 'rainbow', '~> 3.0'
  spec.add_runtime_dependency 'rake', '~> 13.0'
  spec.add_runtime_dependency 'safe_yaml', '~> 1.0'
  spec.add_runtime_dependency 'wax_iiif', '~> 0.2'

  spec.add_development_dependency 'rspec', '~> 3'
end
