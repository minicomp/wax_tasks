include FileUtils
require 'wax_tasks'

namespace :wax do
  namespace :push do
    desc 'push built site to s3 branch'
    task :s3 do
      if ENV['CI']
        next if ENV['TRAVIS_PULL_REQUEST']
        REPO_SLUG = ENV['TRAVIS_REPO_SLUG']
        USER = REPO_SLUG.split('/')[0]
        TOKEN = ENV['ACCESS_TOKEN']
        COMMIT_MSG = "Site updated via #{ENV['TRAVIS_COMMIT']}".freeze
        ORIGIN = "https://#{USER}:#{TOKEN}@github.com/#{REPO_SLUG}.git".freeze
        puts "Deploying to s3 branch from Travis as #{USER}"
      else
        ORIGIN = `git config --get remote.origin.url`.freeze
        COMMIT_MSG = "Site updated at #{Time.now.utc}".freeze
        puts 'Deploying to s3 branch from local task'
      end

      Dir.mktmpdir do |tmp|
        cp_r '_site/.', tmp
        Dir.chdir tmp
        system 'git init'
        system "git add . && git commit -m '#{COMMIT_MSG}'"
        system "git remote add origin #{ORIGIN}"
        system 'git push origin master:refs/heads/s3 --force'
      end
    end
  end
end
