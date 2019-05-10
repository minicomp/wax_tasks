# frozen_string_literal: true

describe WaxTasks::Runner do
  include_context 'shared'

  before(:all) do
    WaxTasks::Test.reset
  end

  describe '.new' do
    context 'with config from default file' do
      it 'runs without errors' do
        expect { WaxTasks::Runner.new }.not_to raise_error
      end
    end

    context 'with custom hash config' do
      it 'runs without errors' do
        expect { WaxTasks::Runner.new({}) }
      end
    end
  end
end
