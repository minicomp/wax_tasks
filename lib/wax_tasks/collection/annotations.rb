# frozen_string_literal: true
require 'byebug'
#
module WaxTasks
  #
  class Collection
    #
    module Annotations
      #
      #
      def get_source_type(source_path)
        source_type = File.extname source_path # '.yaml' or '.json'
        source_type = '.yaml' if source_type == '.yml'
        source_type
      end

      #
      #
      def annotations_from_annotationdata
        raise Error::MissingSource, "Cannot find annotation data source '#{@annotationdata_source}'" unless Dir.exist? @annotationdata_source

        records = records_from_metadata

        Dir.glob(Utils.safe_join(@annotationdata_source, '*')).map do |path|
          item = WaxTasks::Item.new(path, {})
          item.record      = records.find { |r| r.pid == item.pid }
          item.annotation_config = @config.dig 'annotations'
          warn Rainbow("\nCould not find record in #{@annotationdata_source} for image item #{path}.\n").orange if item.record.nil?
          item
        end.compact
      end

      #
      #
      def write_annotations(dir)
        puts Rainbow("Generating annotations for collection '#{@name}'").cyan
        bar = ProgressBar.new(annotations_from_annotationdata.length)
        bar.write
        annotations_from_annotationdata.map do |item|
          item.annotations.each do |source_path|
            dest_path = "#{Utils.safe_join dir, File.basename(source_path, '.*')}.json"
            # img/derivatives/iiif/annotation/test_collection_0_ocr_paragraph.json
            FileUtils.mkdir_p File.dirname(dest_path)
            next if File.exist? dest_path

            source_type = get_source_type source_path
            case source_type
            when '.yaml'
              # load yaml, write json
              annotationlist = WaxTasks::AnnotationList.new(SafeYAML.load_file(source_path))
              File.write(dest_path, "---\nlayout: none\n---\n#{annotationlist.to_json}\n")

              # add_annotationlist_to_manifest(annotationlist, dest_path)
            when '.json'
              # TODO: handle json input - we assume it has uris in final jekyll-ready form
              #  e.g. {{ '/' | absolute_url }}img/derivatives/iiif/annotation/recipebook_002_clippings.json

              FileUtils.cp source_path, dest_path
            end
          end

          # TODO: do we want to update the item-level csv?

          bar.increment!
          bar.write
          item
        end.flat_map(&:record).compact
      end

      #
      #
      def add_annotationlists_to_manifest(annotationlists)
        dir = 'img/derivatives/iiif/annotation'
        collection_dir_name = File.basename(@annotationdata_source)

        manifest_path = Utils.safe_join File.dirname(dir), collection_dir_name, 'manifest.json'
        manifest_front_matter, manifest_body = File.read(manifest_path).match(/(---\n.+?\n---\n)(.*)/m)[1..2]
        manifest = JSON.parse(manifest_body)
            byebug
        annotationlists.each do |list_path|
          source_type = get_source_type list_path

          list = nil
          canvas_id = nil

          case source_type
          when '.yaml'
            list = SafeYAML.load_file(list_path)
            canvas_id = "#{list['collection']}_#{list['canvas']}"
          when '.json'
            # TODO: encapsulate this yaml/json handling in a class
            list_front_matter, list_body = File.read(list_path).match(/(---\n.+?\n---\n)(.*)/m)[1..2]
            list_yaml = YAML.load list_front_matter
            list = JSON.parse(list_body)
            canvas_id = "#{list_yaml['collection']}_#{list_yaml['canvas']}"
          end
          add_annotationlist_to_manifest(manifest, list, canvas_id)
        end

        # TODO : save only if changed
        File.open(manifest_path, 'w') do |f|
          f.write("#{manifest_front_matter}#{manifest.to_json}")
        end

      end

      #
      #
      def add_annotationlist_to_manifest(manifest, annotationlist, canvas_id)
        # dir: img/derivatives/iiif/annotation
        # annotationlist: <WaxTasks::AnnotationList>
        # annotationlist_uri: img/derivatives/iiif/annotation/test_collection_img_item_1_ocr_paragraph.json
        dir = 'img/derivatives/iiif/annotation'
        annotationlist_uri = annotationlist['uri'] 
        annotationlist_uri ||= annotationlist['@id']

        # TODO: deal with multiple sequences, possibly containing same canvas (?)
        this_canvas = manifest['sequences'][0]['canvases'].find do |canvas|
          canvas['@id'] ==
            "{{ '/' | absolute_url }}img/derivatives/iiif/canvas/#{canvas_id}.json"
        end
byebug
        # TODO: this has to run for annotationlists which are created as json in img/derivatives/iiif/annotations
        this_canvas['otherContent'] ||= []

        # TODO: remove entries for annotationlists that have been deleted

        if this_canvas['otherContent'].find { |c| c['@id'] == annotationlist_uri }
          puts "AnnotationList #{canvas_id} already linked in Manifest"
        else
          this_canvas['otherContent'] << {
            '@id' => annotationlist_uri,
            '@type' => 'sc:AnnotationList'
          }
        end
      end
    end
  end
end
