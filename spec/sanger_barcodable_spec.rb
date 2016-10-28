require 'sanger_barcodeable'
require 'spec_helper'

shared_examples_for 'a modern barcode' do
  subject { SangerBarcodeable::SangerBarcode }

  it 'can freely convert between them using the new models' do
    subject.from_human(human_full).human_barcode.should eq(human_full)
    subject.from_human(human_full).machine_barcode.should eq(ean13)
    subject.from_machine(ean13).human_barcode.should eq(human_full)
    subject.from_machine(ean13).machine_barcode.should eq(ean13)
    subject.from_prefix_and_number(human_prefix, short_barcode).human_barcode.should eq(human_full)
    subject.from_prefix_and_number(human_prefix, short_barcode).machine_barcode.should eq(ean13)
  end
end

describe SangerBarcodeable::SangerBarcode do
  context 'with valid parameters' do
    let(:human_prefix) { 'PR' }
    let(:human_checksum) { 'K' }
    let(:human_full) { 'PR1234K' }
    let(:short_barcode) { 1234 }

    let(:machine_prefix_s) { '450' }
    let(:machine_prefix_i) { 450 }
    let(:ean13) { 4500001234757 }
    let(:pre_ean13) { 450000123475 }
    let(:machine_checksum) { 75 }
    let(:print_checksum) { 7 }

    it_behaves_like 'a modern barcode'
  end

  context 'with low prefix parameters' do
    let(:human_prefix) { 'BD' }
    let(:human_checksum) { 'P' }
    let(:human_full) { 'BD1P' }
    let(:short_barcode) { 1 }

    let(:machine_prefix_s) { '058' }
    let(:machine_prefix_i) { 58 }
    let(:ean13) { 580000001806 }
    let(:pre_ean13) { 58000000180 }
    let(:machine_checksum) { 80 }
    let(:print_checksum) { 8 }

    it_behaves_like 'a modern barcode'
  end

  context 'with invalid parameters' do
    let(:human_prefix) { 'XX' }
    let(:human_checksum) { 'X' }
    let(:human_full) { 'XX1234X' }
    let(:short_barcode) { 1234 }

    let(:machine_prefix) { 450 }
    let(:ean13) { 4500101234757 }
    let(:pre_ean13) { 450010123475 }
    let(:machine_checksum) { 75 }
    let(:print_checksum) { 7 }
  end

  context 'which is too long' do
    let(:human_prefix) { 'PR' }
    let(:short_barcode) { 12345678 }
  end
end
