# frozen_string_literal: true

require 'wax_tasks'
require 'zip'
require 'byebug'

namespace :wax do
  desc 'add basic scaffolding for Wax to an existing jekyll site'
  task :scaffold do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    args.reject! { |a| a.start_with? '-' }
    raise WaxTasks::Error::MissingArguments, Rainbow('You must specify a collection after wax:scaffold').magenta if args.empty?

    config_text = File.read("#{Dir.pwd}/_config.yml")
    config = YAML::safe_load(config_text)
    
    args.each do |coll|
      next if config.dig("collections", coll)

      puts "Making #{coll}"
      mkdir_p "#{Dir.pwd}/_data/raw_images/#{coll}"
      File.open("#{Dir.pwd}/_data/#{coll}.csv", 'w') { |file| file.write("pid,label\n") }

      config["collections"] ||= {}
      
      puts "Add #{coll} to _config.yml"
      config["collections"][coll] = {
        "output" =>   true,
        "layout" =>   "wax_item",
        "metadata" => { "source" => "#{coll}.csv" },
        "images" =>   { "source" => "raw_images/#{coll}" }
      }
    end

    puts "Add CORS stanza to _config.yml"
    config["webrick"] = { "header" => { "Access-Control-Allow-Origin" => "*" } }
    
    # FileUtils.cp "#{Dir.pwd}/_config.yml", "#{Dir.pwd}/_config.yml,bak"
    File.open("_config_new.yml", "w"){|f| YAML.dump(config, f)}
    
    framework = File.join(File.dirname(File.expand_path(__FILE__)), '../../wax-framework/.')
    cp_r framework, Dir.pwd
  end
end
