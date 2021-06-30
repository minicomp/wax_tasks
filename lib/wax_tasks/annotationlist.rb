# frozen_string_literal: true

module WaxTasks
  #
  class AnnotationList
    attr_reader :canvas, :label

    def initialize(annotation_list)
      # input is in format of annotation list yaml
      @uri        = annotation_list['uri']
      @collection = annotation_list['collection']
      @canvas     = annotation_list['canvas']
      @label      = annotation_list['label']
      @target     = annotation_list['target']

      @type       = 'sc:AnnotationList'
      @resources  = annotation_list['resources'].map do |resource|
        {
          :@type => resource['type'] || 'cnt:ContentAsText',
          chars: resource['chars'] || '',
          format: resource['format'] || 'text/plain',
          xywh: resource['xywh'] || ''
          # TODO: extend or subclass this as needed for other kinds of annotations
        }
      end
    end

    def to_json
      {
        :@context => 'http://iiif.io/api/presentation/2/context.json',
        :@id => @uri,
        :@type => @type,
        label: @label,
        resources: @resources.map do |resource|
          {
            :@type => 'oa:Annotation',
            motivation: 'sc:painting',
            resource: {
              :@type => resource[:@type],
              format: resource[:format],
              chars: resource[:chars]
            },
            on: "#{@target}#xywh=#{resource[:xywh]}"
          }
        end
      }.to_json
    end

    def save
      path = "#{dir}/#{Utils.slug(@pid)}.md"
      if File.exist? path
        0
      else
        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w') { |f| f.puts "#{@hash.to_yaml}---" }
        1
      end
    end
  end
end
