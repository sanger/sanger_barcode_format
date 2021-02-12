# frozen_string_literal: true

require 'sanger_barcode_format'
require 'spec_helper'

describe SBCF::EmptyBarcode do
  subject { described_class.new }

  let(:empty_sanger_barcode) { SBCF::SangerBarcode.from_human('') }

  it 'does not invalid Sanger Barcodes, even if they were initialized with empty content' do
    expect(subject).not_to eq empty_sanger_barcode
  end

  it 'equals other instances of the same class' do
    expect(subject).to eq described_class.new
  end

  it 'matches nil' do
    expect(subject =~ nil).to be true
  end

  it 'matches ""' do
    expect(subject =~ '').to be true
  end

  it 'does not match other content' do
    expect(subject =~ 'other').to be false
  end

  it 'converts to the string [empty]' do
    expect(subject.to_s).to eq('[empty]')
  end
end
