# frozen_string_literal: true

describe WaxTasks::Site do
  include_context 'shared'

  let(:site_from_config_file)    { WaxTasks::Site.new(config_from_file) }
  let(:site_from_empty_config)   { WaxTasks::Site.new(empty_config) }
  let(:site_from_invalid_config) { WaxTasks::Site.new(invalid_content_config) }
  let(:csv)                      { args_from_file.first }
  let(:json)                     { args_from_file[1] }
  let(:yaml)                     { args_from_file[2] }

  before(:all) do
    WaxTasks::Test.reset
  end

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

  describe '#generate_simple_derivatives' do
    let(:dir) { "#{BUILD}/img/derivatives/simple" }
    let(:item) { 'img_item_1' }
    let(:defaults) { %w[thumbnail full] }
    let(:custom) { %w[tiny retina] }

    context 'when given the name of a valid collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_simple_derivatives(csv) } }.not_to raise_error
      end
    end

    context 'with given an invalid collection name' do
      it 'raises WaxTasks::Error::InvalidCollection' do
        expect { quiet_stdout { site_from_empty_config.generate_simple_derivatives('test') } }.to raise_error(WaxTasks::Error::InvalidCollection)
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
        expect { quiet_stdout { site_from_config_file.generate_simple_derivatives(json) } }.not_to raise_error
      end

      it 'generates the default variants' do
        defaults.each { |v| expect(File.exist?("#{dir}/#{item}/#{v}.jpg")) }
      end

      it 'generates the custom variants' do
        custom.each { |v| expect(File.exist?("#{dir}/#{item}/#{v}.jpg")) }
      end
    end

    context 'when given an invalid (too large) custom variant' do
      it 'raises WaxTasks::Error::InvalidConfig' do
        expect { quiet_stdout { site_from_config_file.generate_simple_derivatives(yaml) } }.to raise_error(WaxTasks::Error::InvalidConfig)
      end
    end
  end

  describe 'generate_iiif_derivatives' do
    context 'when when given the name of a valid collection' do
      it 'runs without errors' do
        site_from_config_file.generate_iiif_derivatives(csv)
      end
    end
  end

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
end
