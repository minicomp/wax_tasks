# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'generate annotationlists from local yaml files'
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
  
      annotationlists = Dir.glob("#{annotationdata_source}/**/*.{yaml,yml,json}").sort

      byebug

        # dir: img/derivatives/iiif/annotation
        # annotationlist: <WaxTasks::AnnotationList>
        # path: img/derivatives/iiif/annotation/test_collection_img_item_1_ocr_paragraph.json

      site.add_annotationlist_to_manfest(dir, annotationlists, path)
    end
  end
end
