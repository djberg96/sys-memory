require 'sys-memory'

RSpec.describe Sys::Memory do
  context 'Sys::Memory::VERSION' do
    example 'the version constant is set to the expected value' do
      expect(described_class::VERSION).to eq('0.1.0')
      expect(described_class::VERSION).to be_frozen
    end
  end

  context 'Sys::Memory.memory' do
    example 'the memory singleton method is defined' do
      expect(described_class).to respond_to(:memory)
    end

    example 'the memory method returns the expected hash' do
      expect(described_class.memory).to be_kind_of(Hash)
    end
  end
end
