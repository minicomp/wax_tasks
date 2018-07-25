context WaxTasks::Branch do
  include_context 'shared'

  before(:all) do
    WaxTasks::Test.reset
  end
  let(:local_branch) do
    runner = WaxTasks::TaskRunner.new
    WaxTasks::LocalBranch.new(runner.site, 'test-branch')
  end
  let(:travis_branch) do
    ENV['TRAVIS_REPO_SLUG'] = 'mnyrop/wax_tasks'
    ENV['ACCESS_TOKEN']     = 'my-super-secret-git-token'
    ENV['TRAVIS_COMMIT']    = 'my inital commit #'

    runner = WaxTasks::TaskRunner.new
    WaxTasks::TravisBranch.new(runner.site, 'test-branch')
  end

  context WaxTasks::LocalBranch do
    describe '.new' do
      it 'gets the target' do
        expect(local_branch.target).to eq('test-branch')
      end

      it 'gets the origin' do
        expect(local_branch.origin).to start_with('https://')
        expect(local_branch.origin).to end_with('wax_tasks.git')
      end

      it 'gets the commit message' do
        expect(local_branch.commit_msg).to start_with('Updated via')
      end

      it 'gets the baseurl' do
        expect(local_branch.baseurl).to eq('wax_tasks')
      end
    end

    describe '.rebuild' do
      it 'runs without errors' do
        expect{ quiet_stdout{ local_branch.rebuild } }.not_to raise_error
      end

      it 'builds the _site' do
        expect(Dir.glob('_site/*')).not_to be_empty
      end
    end
  end

  context WaxTasks::TravisBranch do
    describe '.new' do
      it 'gets the target' do
        expect(travis_branch.target).to eq('test-branch')
      end

      it 'gets the origin' do
        expect(travis_branch.origin).to start_with('https://')
        expect(travis_branch.origin).to end_with('wax_tasks.git')
      end

      it 'gets the commit message' do
        expect(travis_branch.commit_msg).to start_with('Updated via')
      end

      it 'gets the baseurl' do
        expect(travis_branch.baseurl).to eq('wax_tasks')
      end
    end

    describe '.rebuild' do
      it 'runs without errors' do
        expect{ quiet_stdout{ travis_branch.rebuild } }.not_to raise_error
      end

      it 'builds the _site' do
        expect(Dir.glob('_site/*')).not_to be_empty
      end
    end
  end
end
