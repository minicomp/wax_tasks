# frozen_string_literal: true

#
module WaxTasks
  #
  class Collection
    #
    module Annotations
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
          item.annotations.each do |p|
            path = "#{Utils.safe_join dir, File.basename(p, '.*')}.json"
            # img/derivatives/iiif/annotation/test_collection_0_ocr_paragraph.json
            FileUtils.mkdir_p File.dirname(path)
            next if File.exist? path

            # load yaml, write json
            annotationlist = WaxTasks::AnnotationList.new(YAML.load_file(p, safe: true))
            File.write(path, "---\nlayout: none\n---\n#{annotationlist.to_json}\n")

            add_annotationlist_to_manfest(dir, annotationlist, path)
          end

          # TODO: do we want to update the item-level csv?

          bar.increment!
          bar.write
          item
        end.flat_map(&:record).compact
      end

      #
      #
      def add_annotationlist_to_manfest(dir, annotationlist, path)
        collection_dir_name = File.basename(@annotationdata_source)
        manifest_path = Utils.safe_join File.dirname(dir), collection_dir_name, 'manifest.json'
        raw_yaml, raw_json = File.read(manifest_path).match(/(---\n.+?\n---\n)(.*)/m)[1..2]
        manifest = JSON.parse(raw_json)
        canvas_id = "#{collection_dir_name}_#{annotationlist.name}"

        this_canvas = manifest['sequences'][0]['canvases'].find do |canvas|
          canvas['@id'] ==
            "{{ '/' | absolute_url }}img/derivatives/iiif/canvas/#{canvas_id}.json"
        end

        # TODO: allow multiple annotationlists
        # TODO: this has to run for annotationlists which are created as json in img/derivatives/iiif/annotations
        if this_canvas.dig('otherContent', 0, '@id') ==
           "{{ '/' | absolute_url }}#{path}"
          puts "AnnotationList #{canvas_id} already linked in Manifest"
        else
          this_canvas['otherContent'] = [
            {
              '@id' => "{{ '/' | absolute_url }}#{path}",
              '@type' => 'sc:AnnotationList'
            }
          ]
          File.open(manifest_path, 'w') { |f| f.write("#{raw_yaml}#{manifest.to_json}") }
        end
      end
    end
  end
end
