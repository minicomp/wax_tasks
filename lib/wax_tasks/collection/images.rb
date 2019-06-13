# frozen_string_literal: true

require 'mini_magick'
require 'progress_bar'
require 'wax_iiif'

#
module WaxTasks
  #
  class Collection
    #
    module Images
      #
      #
      def image_variants
        default_variants = { 'thumbnail' => 250, 'full' => 1140 }
        custom_variants  = @config.dig('images', 'variants') || {}
        default_variants.merge custom_variants
      end

      #
      #
      def items_from_imagedata
        raise Error::MissingSource, "Cannot find image data source '#{@imagedata_source}'" unless Dir.exist? @imagedata_source

        pre_process_pdfs
        records = records_from_metadata
        Dir.glob(Utils.safe_join(@imagedata_source, '*')).map do |path|
          item = WaxTasks::Item.new(path, @image_variants)
          if item.valid?
            item.record      = records.find { |r| r.pid == item.pid }
            item.iiif_config = @config.dig 'images', 'iiif'
            warn Rainbow("\nWarning:\nCould not find record in #{@metadata_source} for image item #{path}.\n").orange if item.record.nil?
            item
          else
            puts Rainbow("Skipping #{path} because type #{item.type} is not an accepted format").yellow unless item.type == '.pdf'
          end
        end.compact
      end

      #
      #
      def pre_process_pdfs
        Dir.glob(Utils.safe_join(@imagedata_source, '*.pdf')).each do |path|
          target_dir = path.gsub '.pdf', ''
          next unless Dir.glob("#{target_dir}/*").empty?

          puts Rainbow("\nPreprocessing #{path} into image files. This may take a minute.\n").cyan
          opts = { output_dir: File.dirname(target_dir) }
          WaxIiif::Utilities::PdfSplitter.split(path, opts)
        end
      end

      #
      #
      def write_simple_derivatives(dir)
        puts Rainbow("Generating simple image derivatives for collection '#{@name}'\nThis might take awhile.").cyan

        bar = ProgressBar.new(items_from_imagedata.length)
        items_from_imagedata.map do |item|
          item.simple_derivatives.each do |d|
            path = "#{dir}/#{d.path}"
            FileUtils.mkdir_p File.dirname(path)
            next if File.exist? path

            d.img.write path
            item.record.set d.label, path if item.record?
          end
          bar.increment!
          bar.write
          item
        end.flat_map(&:record)
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

        add_font_matter_to_json_files dir
        add_iiif_results_to_records items.map(&:record), builder.manifests
      end
    end
  end
end
