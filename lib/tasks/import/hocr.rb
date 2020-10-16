require 'addressable/template'
require 'json'
require 'nokogiri'
require 'yaml'

require 'byebug'

# adapted from Okracoke:
# https://github.com/NCSU-Libraries/ocracoke/blob/master/app/processing_helpers/hocr_open_annotation_creator.rb
module WaxTasks
class HocrOpenAnnotationCreator

  def initialize(args)
    @hocr = File.open(args[:hocr_path]){ |f| Nokogiri::XML(f) }
    @collection = args[:collection]
    @identifier = args[:canvas]
    @granularity = args[:granularity]

    @uri_root = "{{ '/' | absolute_url }}\img/derivatives/iiif"
    @canvas_root = "#{@collection}_#{@identifier}"
    @label = "#{@canvas_root}_ocr_#{@granularity}"

    @canvas_uri = "#{@uri_root}/canvas/#{@canvas_root}.json"
    @list_uri = "#{@uri_root}/annotation/#{@label}.json"

    @selector = get_selector
  end

  def manifest_canvas_on_xywh(id, xywh)
    "#{@canvas_uri}#xywh=#{xywh}"
  end

  def get_selector
    if @granularity == "word"
     "ocrx_word"
    elsif @granularity == "line"
     "ocr_line"
    elsif @granularity == "paragraph"
      "ocr_par"
    else
      ""
     end
 end

 def resources
    @hocr.xpath(".//*[contains(@class, '#{@selector}')]").map do |chunk|
      text = chunk.text().gsub("\n", ' ').squeeze(' ').strip
      if !text.empty?
        title = chunk['title']
        title_parts = title.split('; ')
        xywh = '0,0,0,0'
        title_parts.each do |title_part|
          if title_part.include?('bbox')
            match_data = /bbox\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/.match title_part
            x = match_data[1].to_i
            y = match_data[2].to_i
            x1 = match_data[3].to_i
            y1 = match_data[4].to_i
            w = x1 - x
            h = y1 - y
            xywh = "#{x},#{y},#{w},#{h}"
          end
        end
        annotation(text, xywh)
       end
    end.compact
  end

  def annotation_list
    {
      :"@context" => "http://iiif.io/api/presentation/2/context.json",
      :"@id" => annotation_list_id,
      :"@type" => "sc:AnnotationList",
      :"@label" => "OCR text with granularity of #{@granularity}",
      resources: resources
    }
  end

  def annotation_list_id_base
    "{{ '/' | absolute_url }}\
img/derivatives/iiif/canvas/\
#{@collection}/#{@identifier}-annotation-list-#{@granularity}.json"

    #File.join OKRACOKE_BASE_URL, @identifier + '-annotation-list-' + @granularity
  end

  def annotation_list_id
    annotation_list_id_base + '.json'
  end

  def annotation(chars, xywh)
    {
      :"@id" => annotation_id(xywh),
      :"@type" => "oa:Annotation",
      motivation: "sc:painting",
      resource: {
        :"@type" => "cnt:ContentAsText",
        format: "text/plain",
        chars: chars
      },
      # TODO: use canvas_url_template
      on: on_canvas(xywh)
    }
  end

  def annotation_id(xywh)
    File.join annotation_list_id_base, xywh
  end

  def on_canvas(xywh)
    manifest_canvas_on_xywh(@identifier, xywh)
  end

  def to_json
    annotation_list.to_json
  end

  def id
    @identifier
  end

  def to_yaml
    yaml_list = {
      'uri' => @list_uri,
      'collection' => @collection,
      'id' => @identifier,
      'label' => @label,
      'target' => @canvas_uri,
      'resources' => []
    }
    annotation_list[:resources].each do |resource|
      yaml_list['resources'] << {
        'xywh' => resource[:@id].sub(/.*\/(.*)/, '\1'),
        'chars' => resource[:resource][:chars]
      }
    end
    yaml_list.to_yaml
  end
  
  def save
    FileUtils.mkdir_p("./_data/annotations/#{@collection}/#{@collection}")
    # TODO: handle item as distinct from collection
    # TODO: do not overwrite existing file without asking
    File.open("./_data/annotations/#{@collection}/#{@collection}/#{@collection}_#{@identifier}_ocr_#{@granularity}.yaml", 'w') do |file|
      file.write(to_yaml)
    end
  end

end
end
