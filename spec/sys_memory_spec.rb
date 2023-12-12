# frozen_string_literal: true

require 'active_support/core_ext/numeric/bytes'
require 'sys-memory'

RSpec.describe Sys::Memory do
  context 'Sys::Memory::VERSION' do
    example 'the version constant is set to the expected value' do
      expect(described_class::VERSION).to eq('0.1.3')
      expect(described_class::VERSION).to be_frozen
    end
  end

  context 'Sys::Memory.memory' do
    example 'the memory singleton method is defined' do
      expect(described_class).to respond_to(:memory)
    end

    example 'the memory singleton method returns the expected hash' do
      expect(described_class.memory).to be_kind_of(Hash)
      expect(described_class.memory.size).to be > 4
    end
  end

  context 'Sys::Memory.total' do
    example 'the total singleton method is defined' do
      expect(described_class).to respond_to(:total)
    end

    example 'the total singleton method returns a sane value' do
      expect(described_class.total).to be > 64.megabytes
    end
  end

  context 'Sys::Memory.free' do
    example 'the free singleton method is defined' do
      expect(described_class).to respond_to(:free)
    end

    example 'the free singleton method returns a sane value' do
      expect(described_class.free).to be > 64.megabytes
    end
  end

  context 'Sys::Memory.used' do
    example 'the used singleton method is defined' do
      expect(described_class).to respond_to(:used)
    end

    example 'the used singleton method returns a sane value' do
      expect(described_class.used).to be > 64.megabytes
    end
  end

  context 'Sys::Memory.load' do
    example 'the load singleton method is defined' do
      expect(described_class).to respond_to(:load)
    end

    example 'the load singleton method returns a sane value' do
      expect(described_class.load).to be > 1
    end
  end
end
