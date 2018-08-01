describe WaxTasks::Utils do
  include_context 'shared'

  let(:valid_data) { WaxTasks::Utils.validate_csv('_data/valid.csv') }
  let(:missing_pid_data) { WaxTasks::Utils.validate_json('_data/missing_pid.json') }
  let(:nonunique_data) { WaxTasks::Utils.validate_csv('_data/duplicate_pid.csv') }

  describe '.construct_permalink' do
    context 'when pretty' do
      it 'ends permalinks with /' do
        ending = WaxTasks::Utils.construct_permalink({ permalink: 'pretty' })
        expect(ending).to eq('/')
      end
    end
    context 'else' do
      it 'ends permalinks with .html' do
        ending = WaxTasks::Utils.construct_permalink({})
        expect(ending).to eq('.html')
      end
    end
  end

  describe '.assert_pids' do
    context 'when given valid data' do
      it 'passes' do
        data = quiet_stdout { WaxTasks::Utils.assert_pids(valid_data) }
        expect(data.length).not_to be_zero
      end
    end

    context 'when given data with missing pid' do
      it 'throws WaxTasks::Error::MissingPid' do
        expect { quiet_stdout { WaxTasks::Utils.assert_pids(missing_pid_data) } }.to raise_error(WaxTasks::Error::MissingPid)
      end
    end
  end

  describe '.assert_unique' do
    context 'when given valid data' do
      it 'passes' do
        data = quiet_stdout { WaxTasks::Utils.assert_unique(valid_data) }
        expect(data.length).not_to be_zero
      end
    end

    context 'when given data with non-unique pids' do
      it 'throws WaxTasks::Error::NonUniquePid' do
        expect { quiet_stdout { WaxTasks::Utils.assert_unique(nonunique_data) } }.to raise_error(WaxTasks::Error::NonUniquePid)
      end
    end
  end

  describe '.validate_csv' do
    context 'with a valid csv file' do
      it 'loads data as a hash array' do
        expect(WaxTasks::Utils.validate_csv('_data/valid.csv').length).not_to be_zero
      end
    end

    context 'with an invalid csv file' do
      it 'thows WaxTasks::Error::InvalidCSV' do
        expect { WaxTasks::Utils.validate_csv('_data/invalid.csv') }.to raise_error(WaxTasks::Error::InvalidCSV)
      end
    end
  end

  describe '.validate_json' do
    context 'with a valid json file' do
      it 'loads data as a hash array' do
        expect(WaxTasks::Utils.validate_json('_data/valid.json').length).not_to be_zero
      end
    end

    context 'with an invalid json file' do
      it 'thows WaxTasks::Error::InvalidJSON' do
        path = '../spec/fake/data/invalid.json'
        expect { WaxTasks::Utils.validate_json('_data/invalid.json') }.to raise_error(WaxTasks::Error::InvalidJSON)
      end
    end
  end

  describe '.validate_yaml' do
    context 'with a valid yaml file' do
      it 'loads data as a hash array' do
        expect(WaxTasks::Utils.validate_yaml('_data/valid.yml').length).not_to be_zero
      end
    end

    context 'with an invalid yaml file' do
      it 'thows WaxTasks::Error::InvalidYAML' do
        expect { WaxTasks::Utils.validate_yaml('_data/invalid.yml') }.to raise_error(WaxTasks::Error::InvalidYAML)
      end
    end
  end
end

describe 'Monkey Patches' do
  describe 'String' do
    describe '.html_strip' do
      it 'strips yaml, html, and some special characters' do
        string = '---fiugkafkb\/\.\:%---\n"P<div></span786g>'
        expect(string.html_strip).to eq('\'P')
      end
    end

    describe '.remove_diacritics' do
      it 'swaps out øéÏŖŗŘřŚś for oeIRrRrSs' do
        string = 'øéÏŖŗŘřŚś'
        expect(string.remove_diacritics).to eq('oeIRrRrSs')
      end
    end

    describe '.remove_yaml' do
      it 'removes yaml' do
        string = "---\nthe yaml\n---\nthe content"
        expect(string.remove_yaml).to eq("\nthe content")
      end
    end

    describe '.slug' do
      it 'slugifies' do
        string = "Effulge\n[ce' bl^s/p/\/hems squam{ous sing}ular_abno...."
        expect(string.slug).not_to include(' ')
      end
    end

  end

  describe 'Array' do
    describe '.normalize' do
      context 'when it includes Hashes' do
        it 'returns itself for Lunr result display' do
          array = [{ test: 1 }, { test: 2 }]
          expect(array.normalize).to eq(array)
        end
      end
      context 'when it includes Strings' do
        it 'joins itself as s String for Lunr result display' do
          array = ['test1', 'test2']
          expect(array.normalize).to eq('test1, test2')
        end
      end
    end
  end
end
