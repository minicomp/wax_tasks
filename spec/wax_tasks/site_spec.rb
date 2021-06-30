# frozen_string_literal: true

describe WaxTasks::Site do
  include_context 'shared'

  before(:all) do
    Test.reset
  end

  #
  # ===================================================
  # SITE.NEW (CONFIG)
  # ===================================================

  describe '#new' do
    context 'when initialized with valid config hash from file' do
      it 'runs without errors' do
        expect { WaxTasks::Site.new(config_from_file) }.not_to raise_error
      end

      it 'merges config with defaults as Hash' do
        expect(WaxTasks::Site.new(config_from_file).config).to be_a(WaxTasks::Config)
      end
    end

    context 'when initialized with empty config hash' do
      it 'runs without errors' do
        expect { WaxTasks::Site.new(empty_config) }.not_to raise_error
      end

      it 'merges config with defaults as Hash' do
        expect(WaxTasks::Site.new(empty_config).config).to be_a(WaxTasks::Config)
      end
    end

    context 'when initialized with an invalid config file' do
      it 'raises WaxTasks::Error::InvalidConfig' do
        expect { WaxTasks::Site.new(invalid_format_config) }.to raise_error(WaxTasks::Error::InvalidConfig)
      end
    end
  end

  #
  # ===================================================
  # SITE.COLLECTIONS
  # ===================================================
  #
  describe '#collections' do
    context 'when initialized with config hash from file' do
      let(:collections) { site_from_config_file.collections }
      it 'returns an array of Collection objects' do
        expect(collections).to be_an(Array)
        expect(collections.first).to be_a(WaxTasks::Collection)
      end
    end

    context 'when initialized with empty config hash' do
      let(:collections) { site_from_empty_config.collections }
      it 'returns an empty array' do
        expect(collections).to be_an(Array)
        expect(collections).to be_empty
      end
    end
  end

  #
  # ===================================================
  # SITE.GENERATE_PAGES (NAME)
  # ===================================================
  #
  describe '#generate_pages' do
    context 'when given name of a valid csv collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_pages(csv) } }.not_to raise_error
      end

      it 'generates pages' do
        pages = Dir.glob("#{BUILD}/_#{csv}/*.md")
        expect(pages.length).to eq(4)
      end
    end

    context 'when given name of a valid json collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_pages(json) } }.not_to raise_error
      end

      it 'generates correct pages' do
        pages = Dir.glob("#{BUILD}/_#{json}/*.md")
        expect(pages.length).to eq(4)
      end
    end

    context 'when given name of a valid yaml collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_pages(yaml) } }.not_to raise_error
      end

      it 'generates correct pages' do
        pages = Dir.glob("#{BUILD}/_#{yaml}/*.md")
        expect(pages.length).to eq(4)
      end
    end

    context 'when given the name of a non-existing collection' do
      it 'raises WaxTasks::Error::InvalidCollection' do
        expect { quiet_stdout { site_from_config_file.generate_pages('not_a_collection') } }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end

    context 'when given an invalid metadata file format (.xls)' do
      it 'raises WaxTasks::Error::InvalidSource' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('xls_collection') } }.to raise_error(WaxTasks::Error::InvalidSource)
      end
    end

    context 'when given path to a metadata file that doesnt exist' do
      it 'raises WaxTasks::Error::MissingSource' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('missing_source_collection') } }.to raise_error(WaxTasks::Error::MissingSource)
      end
    end

    context 'when given an invalid csv as a metadata file' do
      it 'raises WaxTasks::Error::InvalidCSV' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('invalid_csv_collection') } }.to raise_error(WaxTasks::Error::InvalidCSV)
      end
    end

    context 'when given an invalid json as a metadata file' do
      it 'raises WaxTasks::Error::InvalidJSON' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('invalid_json_collection') } }.to raise_error(WaxTasks::Error::InvalidJSON)
      end
    end

    context 'when given an invalid yaml as a metadata file' do
      it 'raises WaxTasks::Error::InvalidYAML' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('invalid_yaml_collection') } }.to raise_error(WaxTasks::Error::InvalidYAML)
      end
    end

    context 'when given a metadata file with duplicate pid values' do
      it 'raises WaxTasks::Error::WaxTasks::Error::NonUniquePid' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('duplicate_pid_collection') } }.to raise_error(WaxTasks::Error::NonUniquePid)
      end
    end

    context 'when given a metadata file records missing a pid value' do
      it 'raises WaxTasks::Error::WaxTasks::Error::MissingPid' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('missing_pid_collection') } }.to raise_error(WaxTasks::Error::MissingPid)
      end
    end
  end

  #
  # ===================================================
  # SITE.GENERATE_STATIC_SEARCH (NAME)
  # ===================================================
  #
  describe '#generate_static_search' do
    context 'with valid config' do
      context 'and valid search name' do
        it 'runs without errors' do
          expect { quiet_stdout { site_from_config_file.generate_static_search('main') } }.not_to raise_error
        end

        it 'generates a search index as valid JSON to expected path' do
          expect { JSON.parse(WaxTasks::Utils.remove_yaml(File.read("#{BUILD}/js/lunr-index.json"))) }.not_to raise_error
        end
      end

      context 'and invalid search name' do
        it 'throws WaxTasks::Error::InvalidConfig' do
          expect { site_from_config_file.generate_static_search('not_a_search') }.to raise_error(WaxTasks::Error::InvalidConfig)
        end
      end
    end

    context 'with empty search config' do
      it 'throws WaxTasks::Error::InvalidConfig' do
        expect { site_from_empty_config.generate_static_search('main') }.to raise_error(WaxTasks::Error::InvalidConfig)
      end
    end
  end

  #
  # ===================================================
  # SITE.GENERATE_DERIVATIVES (NAME)
  # ===================================================
  #
  describe '#generate_derivatives type=simple' do
    let(:dir) { "#{BUILD}/img/derivatives/simple" }
    let(:item) { 'img_item_1' }
    let(:defaults) { %w[thumbnail full] }
    let(:custom) { %w[tiny retina] }

    context 'when given the name of a valid csv collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_derivatives(csv, 'simple') } }.not_to raise_error
      end
    end

    context 'when given an valid json collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_derivatives(json, 'simple') } }.not_to raise_error
      end
    end

    context 'with given an invalid collection name' do
      it 'raises WaxTasks::Error::InvalidCollection' do
        expect { quiet_stdout { site_from_empty_config.generate_derivatives('test', 'simple') } }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end

    context 'when not given custom variant widths' do
      it 'generates the defaults' do
        defaults.each do |variant|
          expect(File.exist?("#{dir}/#{item}/#{variant}.jpg"))
        end
      end
    end

    context 'when given valid custom variants widths' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_derivatives(json, 'simple') } }.not_to raise_error
      end

      it 'generates the default variants' do
        defaults.each { |v| expect(File.exist?("#{dir}/#{item}/#{v}.jpg")) }
      end

      it 'generates the custom variants' do
        custom.each { |v| expect(File.exist?("#{dir}/#{item}/#{v}.jpg")) }
      end
    end

    context 'when requesting an invalid (too large) custom variant' do
      it 'skips resizing, warns, and uses the original image' do
        expect { quiet_stdout { site_from_invalid_config.generate_derivatives('xl_variant', 'simple') } }.not_to raise_error
      end
    end
  end

  describe '#generate_derivatives type=iiif' do
    let(:dir) { "#{BUILD}/img/derivatives/iiif/images" }
    let(:item) { 'img_item_1' }
    let(:defaults) { %w[250 1140] }
    let(:custom) { %w[50 1400] }

    context 'with iiif config vars' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_derivatives(yaml, 'iiif') } }.not_to raise_error
      end
    end

    context 'without iiif config vars' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_derivatives(json, 'iiif') } }.not_to raise_error
      end
    end

    context 'when given valid custom variants widths' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_derivatives(json, 'iiif') } }.not_to raise_error
      end

      it 'generates the default variants' do
        defaults.each { |v| expect(File.exist?("#{dir}/#{item}/full/#{v},/0/default.jpg")) }
      end

      it 'generates the custom variants' do
        custom.each { |v| expect(File.exist?("#{dir}/#{item}/full/#{v},/0/default.jpg")) }
      end
    end
  end

  #
  # ===================================================
  # SITE.GENERATE_ANNOTATIONLISTS (NAME)
  # ===================================================
  #

  describe '#generate_annotationlists' do
    before(:example) do
      FileUtils.mkdir_p "#{BUILD}/_data/annotations/test_collection/dir_imgs_item/"
      FileUtils.cp Dir.glob("#{ROOT}/spec/sample_hocr/*.yaml"), "#{BUILD}/_data/annotations/test_collection/dir_imgs_item/"
    end

    # TODO: mock or stub the annotation and manifest files, break up this block
    context 'when generates sample annotationlist' do
      it 'runs without error' do
        expect { site_from_config_file.generate_annotations('csv_collection') }.not_to raise_error
      end

      it 'generates annotationlist' do
        json_file = "#{BUILD}/img/derivatives/iiif/annotation/test_collection_img_item_1_ocr_paragraph.json"
        expect(File).to exist(json_file)
        raw_yaml, raw_json = File.read(json_file).match(/(---\n.+?\n---\n)(.*)/m)[1..2]
        annotation = JSON.parse(raw_json)['resources'].first
        expect(annotation['on']).to eq("{{ '/' | absolute_url }}img/derivatives/iiif/canvas/test_collection_img_item_1.json#xywh=20,668,171,100")
        expect(annotation['resource']['chars']).to eq('If the ax falls the')
      end
    end

    after(:example) do
      FileUtils.rm Dir.glob("#{BUILD}/_data/annotations/test_collection/dir_imgs_item/*.yaml")
      FileUtils.rm Dir.glob("#{BUILD}/img/derivatives/iiif/test_collection/manifest.json")
    end
  end

end
