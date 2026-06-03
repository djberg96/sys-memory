# frozen_string_literal: true

require 'active_support/core_ext/numeric/bytes'
require 'sys-memory'

RSpec.describe Sys::Memory do
  let(:memory) { described_class.memory }

  let(:swap_keys) do
    [
      %i[swap_size swap_free],
      %i[swap_total swap_available],
      %w[SwapTotal SwapFree],
      %w[TotalPageFile AvailPageFile]
    ].find { |total_key, free_key| memory.key?(total_key) && memory.key?(free_key) }
  end

  context 'Sys::Memory::VERSION' do
    example 'the version constant is set to the expected value' do
      expect(described_class::VERSION).to eq('0.2.1')
      expect(described_class::VERSION).to be_frozen
    end
  end

  context 'Sys::Memory.memory' do
    example 'the memory singleton method is defined' do
      expect(described_class).to respond_to(:memory)
    end

    example 'the memory singleton method returns the expected hash' do
      expect(described_class.memory).to be_a(Hash)
      expect(described_class.memory.size).to be > 4
    end

    example 'the memory singleton method returns non-negative numeric values' do
      described_class.memory.each do |key, value|
        expect(value).to be_a(Numeric), "#{key.inspect} should be numeric"
        expect(value).to be >= 0
      end
    end

    example 'the memory singleton method returns sane swap values' do
      swap_total, swap_free = swap_keys
      skip 'no swap values reported on this platform' unless swap_total && swap_free

      expect(memory[swap_total]).to be >= 0
      expect(memory[swap_free]).to be_between(0, memory[swap_total]).inclusive
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
