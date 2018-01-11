require 'html-proofer'
require 'iiif_s3'

namespace :wax do
  desc 'run htmlproofer, rspec if exists'
    task :test do
      options = {
      :check_external_hash => true,
      :allow_hash_href => true,
      :check_html => true,
      :check_img_http => true,
      :disable_external => true,
      :empty_alt_ignore => true,
      :only_4xx => true,
      :verbose => true
    }
    begin
      HTMLProofer.check_directory("./_site", options).run
    rescue => msg
      puts "#{msg}"
    end
    if File.exist?('.rspec')
      sh 'bundle exec rspec'
    end
  end
end
