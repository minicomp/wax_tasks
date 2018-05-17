require 'fileutils'
require 'jekyll'
require 'yaml'
require 'faker'

module Fake
  def self.site
    setup('build')

    fake_config
    fake_gemfile
    fake_rakefile
    fake_index

    quiet_output { Bundler.with_clean_env { system('bundle') } }
  end

  def self.setup(site_dir)
    data_dir = site_dir + '/_data'
    image_dir = Dir.glob('spec/sample/iiif')

    FileUtils.mkdir_p(site_dir)
    FileUtils.mkdir_p(data_dir)
    FileUtils.cp_r(image_dir, data_dir)
    FileUtils.cd(site_dir)
  end

  def self.fake_config
    config = {
      'url' => '',
      'decription' => '',
      'collections_dir' => 'collections',
      'theme' => 'minima',
      'js' => {
        'jquery' => {
          'cdn' => 'test',
          'version' => 'test'
        }
      }
    }
    File.open('_config.yml', 'w') { |f| f.puts(config.to_yaml) }
  end

  def self.fake_gemfile
    File.open('Gemfile', 'w') do |f|
      f.puts("source 'https://rubygems.org'")
      f.puts("gem 'jekyll'")
      f.puts("gem 'minima'")
    end
  end

  def self.fake_rakefile
    File.open('Rakefile', 'w') do |f|
      f.puts('Dir.glob("../lib/tasks/*.rake").each { |r| load r }')
    end
  end

  def self.fake_index
    File.open('index.html', 'w') do |f|
      f.puts('<html><head></head><body>Home</body></html>')
    end
  end
end

def quiet_output
  if $quiet
    begin
      orig_stderr = $stderr.clone
      orig_stdout = $stdout.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      retval = yield
    ensure
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
    end
    retval
  else
    yield
  end
end
