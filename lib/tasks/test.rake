require 'wax_tasks'

namespace :wax do
  desc 'run htmlproofer, rspec if exists'
  task :test do
    opts = {
      :check_external_hash => true,
      :allow_hash_href => true,
      :check_html => true,
      :disable_external => true,
      :empty_alt_ignore => true,
      :only_4xx => true,
      :verbose => true
    }
    begin
      HTMLProofer.check_directory('./_site', opts).run
    rescue StandardError
      puts('Failed to run wax:texts. Make sure you are using `bundle exec`.').magenta
    end
    sh 'bundle exec rspec' if File.exist?('.rspec')
  end
end
