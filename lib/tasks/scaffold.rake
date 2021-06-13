# frozen_string_literal: true

require 'wax_tasks'
require 'zip'
require 'byebug'

namespace :wax do
  desc 'add basic scaffolding for Wax to an existing jekyll site'
  namespace :scaffold do
    task :resources do
      config_text = File.read("#{Dir.pwd}/_config.yml")
      config = YAML::safe_load(config_text)

      # CORS stanza and "scaffolded" flags are added if this is the first run
      unless config["scaffolded"]
        new_config = {}
        
        # Add CORS stanza to _config.yml, if missing
        new_config["webrick"] = { "header" => { "Access-Control-Allow-Origin" => "*" } }    

        # add framework documents to jekyll, unless this has already been done
        framework = File.join(File.dirname(File.expand_path(__FILE__)), '../../wax-framework/.')
        cp_r framework, Dir.pwd
        new_config["scaffolded"] = true
 
        new_yaml = new_config.to_yaml.sub("---\n", "")
        config_text.sub! "\ncollections:\n", "\n#{new_yaml}"

        File.open("_config.yml", "w"){ |f| f.puts config_text }
      end
    end
    task :collection do
      args = ARGV.drop(1).each { |a| task a.to_sym }
      args.reject! { |a| a.start_with? '-' }
      raise WaxTasks::Error::MissingArguments, Rainbow('You must specify a collection after wax:scaffold').magenta if args.empty?

      config_text = File.read("#{Dir.pwd}/_config.yml")
      config = YAML::safe_load(config_text)

      config_text += "\ncollections:\n" unless config["collections"]

      new_config = {}

      args.each do |coll|
        # skip if this coll is already configured
        Rainbow("Collection #{coll} is already configured.").magenta if config.dig("collections", coll)
        next if config.dig("collections", coll)

        # Make coll images dir and metadata csv file
        mkdir_p "#{Dir.pwd}/_data/raw_images/#{coll}"
        File.open("#{Dir.pwd}/_data/#{coll}.csv", 'w') { |file| file.write("pid,label\n") }

        new_config["collections"] ||= {}
        
        # Add coll to new config stanzas
        new_config["collections"][coll] = {
          "output" =>   true,
          "layout" =>   "wax_item",
          "metadata" => { "source" => "#{coll}.csv" },
          "images" =>   { "source" => "raw_images/#{coll}" }
        }
      end

      # insert new collection(s) at top of collections list
      # if this is the first scaffold run, the webrick and scaffolded 
      # sections will be added after collections
      new_yaml = new_config.to_yaml.sub("---\n", "")
      config_text.sub! "\ncollections:\n", "\n#{new_yaml}"

      File.open("_config.yml", "w"){ |f| f.puts config_text }
      
    end
  end
end
