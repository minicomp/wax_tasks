# pagemaster task specs
# describe 'wax:pagemaster' do
#   include_context 'shared'
#
#   it 'runs without errors' do
#     passes = quiet_stdout { system("bundle exec rake wax:pagemaster #{valid_args.join ' '}") }
#     expect(passes).to eq(true)
#   end
#
#   it 'generates pages to the correct directories' do
#     valid_pm_collections.each do |c|
#       pages = Dir.glob("#{c.page_dir}/*.md")
#       expect(pages.length).to be > 0
#       Fake.content(pages) # add content to pages to test lunr indexing
#     end
#   end
# end

describe 'PagemasterCollection' do
  include_context 'shared'
  let(:valid_pm_collections) { valid_args.map { |a| PagemasterCollection.new(a) } }
  let(:invalid_collection) do
    PagemasterCollection.new(valid_args.first, { site_config: { 'bad' => nil } })
  end
  let(:missing_pid_data) do
    data = PagemasterCollection.new(valid_args.first).data
    data.first.delete('pid')
    data
  end
  let(:nonunique_data) do
    data = PagemasterCollection.new(valid_args.first).data
    data[3] = data.first.dup
    data
  end

  describe '.new' do
    it 'creates valid collections' do
     expect { valid_pm_collections.all? }
    end
    context 'when an given invalid config' do
      it 'throws NoMethodError' do
        expect { invalid_collection }.to raise_error(NoMethodError)
      end
    end
    context 'when given a collection arg not in config' do
      it 'throws Error::InvalidCollection' do
        expect { quiet_stdout { PagemasterCollection.new('not_a_collection') } }.to raise_error(Error::InvalidCollection)
      end
    end
  end

  describe '.ingest' do
    context 'when given a src file that doesn\'t exist' do
      it 'throws Error::MissingSource' do
        bad_opts = { site_config: { collections: { 'bad' => { 'source' => 'not-a-file.xls' } } } }
        expect { quiet_stdout { PagemasterCollection.new('bad', bad_opts) } }.to raise_error(Error::MissingSource)
      end
    end
    context 'when given data with missing pid' do
      it 'throws Error::MissingPid' do
        expect { quiet_stdout { WaxTasks::Utils.assert_pids(missing_pid_data) } }.to raise_error(Error::MissingPid)
      end
    end
    context 'when given data nonunique pid' do
      it 'throws Error::NonUniquePid' do
        expect { quiet_stdout { WaxTasks::Utils.assert_unique(nonunique_data) } }.to raise_error(Error::NonUniquePid)
      end
    end
  end

  describe '.generate_pages' do
    it 'runs without errors' do
      expect { quiet_stdout { valid_pm_collections.first.generate_pages } }.not_to raise_error
    end

    it 'skips existing pages' do
      expect { valid_pm_collections.first.generate_pages }.to output(/.*Skipping.*/).to_stdout
    end
  end
end
