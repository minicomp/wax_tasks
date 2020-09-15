# frozen_string_literal: true

describe WaxTasks::Config do
  include_context 'shared'

  before(:all) do
    Test.reset
  end

  let(:hash) { { title: 'test' } }
  subject(:simple_hash_config) { WaxTasks::Config.new hash }
  it { should be_a WaxTasks::Config }
end
