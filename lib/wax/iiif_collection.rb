require 'wax_iiif'

# document
class IiifCollection < Collection
  def initialize(name, opts = {})
    super(name, opts)

    @src_dir    = "_data/iiif/#{@name}"
    @target_dir = "./iiif/#{@name}"
    @src_data   = @c_conf.fetch('source', false)
    @i_conf     = @c_conf.fetch('iiif', {})
    @meta       = @i_conf.fetch('meta', false)
    @variants   = validated_variants
  end

  def process
    Error.missing_iiif_src(@src_dir) unless Dir.exist?(@src_dir)
    FileUtils.mkdir_p("./iiif/#{@name}", verbose: false)

    builder = iiif_builder
    builder.load(iiif_records)
    builder.process_data(true)
  end

  def iiif_builder
    build_opts = {
      base_url: "#{@s_conf[:baseurl]}/iiif/#{@name}",
      output_dir: @target_dir,
      verbose: true,
      variants: @variants
    }
    IiifS3::Builder.new(build_opts)
  end

  def validated_variants
    vars = @i_conf.fetch('variants', false)
    if vars.is_a?(Array) && vars.all? { |v| v.is_a?(Integer) }
      variants = {}
      vars.each_with_index { |v, i| variants["custom_variant_#{i}".to_sym] = v }
    else
      variants = { med: 600, lg: 1140 }
    end
    variants
  end

  def iiif_records
    records = []
    source_images = Dir["#{@src_dir}/*"].sort!
    metadata = ingest(@src_data) if @meta && @src_data
    source_images.each { |src_img| records << iiif_record(src_img, metadata) }
    records
  end

  def iiif_record(src_img, metadata)
    basename = File.basename(src_img, '.*').to_s
    record_opts = { id: basename, path: src_img, label: basename }
    if metadata
      src_item = metadata.find { |i| i['pid'].to_s == basename }
      @meta.each { |k, v| record_opts[k.to_sym] = src_item.fetch(v, '') }
    end
    IiifS3::ImageRecord.new(record_opts)
  end
end
