require 'jekyll'

namespace :wax do
  task :gitpub => :config do
    Jekyll::Site.new(Jekyll.configuration({
      "source"      => ".",
      "destination" => _site,
      "config" => "_config.yml",
      "verbose" => true
    })).process

    origin = `git config --get remote.origin.url`

    Dir.mktmpdir do |tmp|
      cp_r "_site/.", tmp
      Dir.chdir tmp

      system "git init" # Init the repo.
      system "git add . && git commit -m 'Site updated at #{Time.now.utc}'"
      system "git remote add origin #{origin}"
      system "git push origin master:refs/heads/gh-pages --force"
    end
  end
end
