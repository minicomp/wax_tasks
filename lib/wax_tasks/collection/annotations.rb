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

            # add to manifest
            # TODO: this should be all done in wax_iiif, really, though
            # the workflow sequencing that implies needs to be thought out

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
          # TODO: do we want to update the item-level csv?

          bar.increment!
          bar.write
          item
        end.flat_map(&:record).compact
      end

      #
      #
      def iiif_builder(dir)
        build_opts = {
          base_url: "{{ '/' | absolute_url }}#{dir}",
          output_dir: dir,
          collection_label: @name
        }
        WaxIiif::Builder.new(build_opts)
      end

      #
      #
      def add_font_matter_to_json_files(dir)
        Dir.glob("#{dir}/**/*.json").each do |f|
          Utils.add_yaml_front_matter_to_file f
        end
      end

      #
      #
      def add_iiif_results_to_records(records, manifests)
        records.map do |record|
          next nil if record.nil?

          manifest = manifests.find { |m| m.base_id == record.pid }
          next record if manifest.nil?

          json = JSON.parse manifest.to_json
          @image_variants.each do |k, _v|
            value = json.dig k
            record.set k, "/#{Utils.content_clean(value)}" unless value.nil?
          end

          record.set 'manifest', "/#{Utils.content_clean(manifest.id)}"
          record
        end.compact
      end

      #
      #
      def write_iiif_derivatives(dir)
        items     = items_from_imagedata
        iiif_data = items.map(&:iiif_image_records).flatten
        builder   = iiif_builder(dir)

        builder.load iiif_data

        puts Rainbow("Generating IIIF derivatives for collection '#{@name}'\nThis might take awhile.").cyan
        builder.process_data
        records = items.map(&:record).compact

        add_font_matter_to_json_files dir
        add_iiif_results_to_records records, builder.manifests
      end
    end
  end
end
