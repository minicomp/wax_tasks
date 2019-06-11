# frozen_string_literal: true

describe WaxTasks::Site do
  include_context 'shared'

  before(:all) do
    Test.reset
  end

  #
  # ===================================================
  # SITE.GENERATE_API (NAME)
  # ===================================================
  #
  describe '#generate_api' do
    context 'when given name of a valid csv collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_api(csv) } }.not_to raise_error
      end

      it 'generates correct pages'

      it 'produces a valid JSONAPI instance'

      it 'reports that 4 json objects were generated to the api'
    end

    context 'when given name of a valid json collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_api(json) } }.not_to raise_error
      end

      it 'generates correct pages'

      it 'produces a valid JSONAPI instance'

      it 'reports that 4 json objects were generated to the api'
    end

    context 'when given name of a valid yaml collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_api(yaml) } }.not_to raise_error
      end

      it 'generates correct pages' 

      it 'produces a valid JSONAPI instance'

      it 'reports that 4 json objects were generated to the api'
    end

    context 'when given the name of a non-existing collection' do
      it 'raises WaxTasks::Error::InvalidCollection' do
        expect { quiet_stdout { site_from_config_file.generate_api('not_a_collection') } }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end

    context 'when given an invalid metadata file format (.xls)' do
      it 'raises WaxTasks::Error::InvalidSource' do
        expect { quiet_stdout { site_from_invalid_config.generate_api('xls_collection') } }.to raise_error(WaxTasks::Error::InvalidSource)
      end
    end

    context 'when given path to a metadata file that doesnt exist' do
      it 'raises WaxTasks::Error::MissingSource' do
        expect { quiet_stdout { site_from_invalid_config.generate_api('missing_source_collection') } }.to raise_error(WaxTasks::Error::MissingSource)
      end
    end

    context 'when given an invalid csv as a metadata file' do
      it 'raises WaxTasks::Error::InvalidCSV' do
        expect { quiet_stdout { site_from_invalid_config.generate_api('invalid_csv_collection') } }.to raise_error(WaxTasks::Error::InvalidCSV)
      end
    end

    context 'when given an invalid json as a metadata file' do
      it 'raises WaxTasks::Error::InvalidJSON' do
        expect { quiet_stdout { site_from_invalid_config.generate_api('invalid_json_collection') } }.to raise_error(WaxTasks::Error::InvalidJSON)
      end
    end

    context 'when given an invalid yaml as a metadata file' do
      it 'raises WaxTasks::Error::InvalidYAML' do
        expect { quiet_stdout { site_from_invalid_config.generate_api('invalid_yaml_collection') } }.to raise_error(WaxTasks::Error::InvalidYAML)
      end
    end

    context 'when given a metadata file with duplicate pid values' do
      it 'raises WaxTasks::Error::WaxTasks::Error::NonUniquePid' do
        expect { quiet_stdout { site_from_invalid_config.generate_api('duplicate_pid_collection') } }.to raise_error(WaxTasks::Error::NonUniquePid)
      end
    end

    context 'when given a metadata file records missing a pid value' do
      it 'raises WaxTasks::Error::WaxTasks::Error::MissingPid' do
        expect { quiet_stdout { site_from_invalid_config.generate_api('missing_pid_collection') } }.to raise_error(WaxTasks::Error::MissingPid)
      end
    end

    context 'when there is invalid api-specific metadata in _config.yml' do
      it 'raises WaxTasks::Error::InvalidJSONAPIConfig' do
        expect { quiet_stdout { site_from_invalid_jsonapi_config.generate_api(csv) } }.to raise_error(WaxTasks::Error::InvalidJSONAPIConfig)
      end
    end
  end

end
