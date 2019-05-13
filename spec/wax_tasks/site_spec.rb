# frozen_string_literal: true

describe WaxTasks::Site do
  include_context 'shared'

  let(:site_from_config_file) do
    site = WaxTasks::Site.new(config_from_file)
    site.source = BUILD
    site
  end
  let(:site_from_empty_config) do
    site = WaxTasks::Site.new(empty_config)
    site.source = BUILD
    site
  end
  let(:site_from_invalid_config) do
    site = WaxTasks::Site.new(invalid_content_config)
    site.source = BUILD
    site
  end

  before(:all) do
    WaxTasks::Test.reset
  end

  describe '#new' do
    context 'when initialized with valid config hash from file' do
      it 'runs without errors' do
        expect { site_from_config_file }.not_to raise_error
      end

      it 'merges config with defaults as Hashie::Mash' do
        expect(site_from_config_file.config).to be_a(Hashie::Mash)
      end
    end

    context 'when initialized with empty config hash' do
      it 'runs without errors' do
        expect { site_from_empty_config }.not_to raise_error
      end

      it 'merges config with defaults as Hashie::Mash' do
        expect(site_from_empty_config.config).to be_a(Hashie::Mash)
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
        expect { quiet_stdout { site_from_config_file.generate_pages(args_from_file.first) } }.not_to raise_error
      end

      it 'generates pages' do
        pages = Dir.glob("#{BUILD}/_csv_collection/*.md")
        expect(pages.length).to be 4
      end
    end

    context 'when given name of a valid json collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_pages(args_from_file[1]) } }.not_to raise_error
      end

      it 'generates correct pages' do
        pages = Dir.glob("#{BUILD}/_json_collection/*.md")
        expect(pages.length).to be 4
      end
    end

    context 'when given name of a valid yaml collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_pages(args_from_file.last) } }.not_to raise_error
      end

      it 'generates correct pages' do
        pages = Dir.glob("#{BUILD}/_yaml_collection/*.md")
        expect(pages.length).to be 4
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
      it 'raises WaxTasks::Error::InvalidSource' do
        expect { quiet_stdout { site_from_invalid_config.generate_pages('missing_source_collection') } }.to raise_error(WaxTasks::Error::InvalidSource)
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


  describe '#generate_static_search' do
    context 'with valid config' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_static_search } }.not_to raise_error
      end
      it 'generates a search index as valid JSON to expected path' do
        expect { JSON.parse(WaxTasks::Utils.remove_yaml(File.read("#{BUILD}/js/lunr-index.json"))) }.not_to raise_error
      end
    end

    context 'with empty search config' do
      it 'throws WaxTasks::Error::InvalidSiteConfig' do
        expect { site_from_empty_config.generate_static_search }.to raise_error(WaxTasks::Error::InvalidSiteConfig)
      end
    end

    context 'with invalid search config' do
      it 'throws WaxTasks::Error::InvalidCollection' do
        expect { site_from_invalid_config.generate_static_search }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end
  end


  describe '#generate_simple_derivatives' do
    context 'when given the name of a valid collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_simple_derivatives(args_from_file.first) } }.not_to raise_error
      end

      context 'with empty collections config' do
        it 'raises WaxTasks::Error::InvalidCollection' do
          expect { quiet_stdout { site_from_empty_config.generate_simple_derivatives('test') } }.to raise_error(WaxTasks::Error::InvalidCollection)
        end
      end
    end
  end
end
