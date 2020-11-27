# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'generate annotationlists from local yaml/json files'
  task :annotations do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    args.reject! { |a| a.start_with? '-' }

    raise WaxTasks::Error::MissingArguments, Rainbow("You must specify a collection after 'wax:annotations'").magenta if args.empty?

    site = WaxTasks::Site.new
    args.each { |a| site.generate_annotations(a) }
  end

  task :updatemanifest do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    args.reject! { |a| a.start_with? '-' }

    raise WaxTasks::Error::MissingArguments, Rainbow("You must specify a collection after 'wax:updatemanifest'").magenta if args.empty?

    site = WaxTasks::Site.new

    args.each do |collection_name|
      collection = site.collections.find { |c| c.name == collection_name }
      annotationdata_source = collection.annotationdata_source

      # TODO: just crawl the item directories
      files = Dir.glob("#{annotationdata_source}/**/*.{yaml,yml,json}").sort
      annotationlists = {}
      files.each do |file|
        # path like _data/annotations/documents/doc9031/doc9031_1.yaml
        filepath = Pathname.new(file)
        pid = filepath.dirname.basename.to_s # doc9031
        annotationlists[pid] ||= []
        annotationlists[pid] << file
      end

      collection.add_annotationlists_to_manifest(annotationlists)
    end
  end
end
