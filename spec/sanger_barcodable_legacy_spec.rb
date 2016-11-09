require 'sanger_barcode_format'
require 'sanger_barcode_format/legacy_methods'
require 'spec_helper'

shared_examples_for 'a legacy barcode' do
  # Seems wrong, why is machine prefix a string, but the rest integers?
  let(:split_barcode) { [machine_prefix_s, short_barcode, machine_checksum] }
  let(:split_human_barcode) { [human_prefix, short_barcode.to_s, human_checksum] }

  it 'calculates the full barcode' do
    subject.calculate_barcode(human_prefix, short_barcode).should eq(ean13)
  end

  it 'calculates a checksum' do
    subject.calculate_checksum(human_prefix, short_barcode).should eq(human_checksum)
  end

  it 'splits a barcode into its components' do
    # Seems wrong, why is machine prefix a string, but the rest integers?
    subject.split_barcode(ean13).should eq(split_barcode)
  end

  it 'splits a human barcode into its components' do
    subject.split_human_barcode(human_full).should eq(split_human_barcode)
  end

  it 'converts machine_barcodes to human' do
    # This method seems badly named to me. Human implies the full 'PR1234K' barcode, not just
    # the short 'barcode' number as stored in the database.
    subject.number_to_human(ean13).should eq(short_barcode.to_s)
  end

  it 'gets the human prefix from the ean13 barcode' do
    subject.prefix_from_barcode(ean13).should eq(human_prefix)
  end

  it 'can convert numeric prefixes to human' do
    subject.prefix_to_human(machine_prefix_i).should eq(human_prefix)
  end

  it 'can convert between human barcodes and machine barcodes' do
    subject.human_to_machine_barcode(human_full).should eq(ean13)
    subject.barcode_to_human(ean13).should eq(human_full)
  end

  it 'can convert to human barcodes with a prefix check' do
    subject.barcode_to_human!(ean13, human_prefix).should eq(human_full)
    expect do
      subject.barcode_to_human!(ean13, 'XX')
    end.to raise_error
  end

  it 'has a vaild ean13' do
    subject.check_EAN(ean13).should eq(true)
  end
end

describe SBCF::LegacyMethods do
  subject do
    module LegacyModule
      extend SBCF::LegacyMethods
    end
  end

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

    it_behaves_like 'a legacy barcode'
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

    it_behaves_like 'a legacy barcode'
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

    it 'has a invaild ean13' do
      subject.check_EAN(ean13).should eq(false)
    end

    it 'will raise on barcode_to_human!' do
      expect do
        subject.barcode_to_human!(ean13, 'XX')
      end.to raise_error
    end

    it 'will raise on human_to_machine_barcode' do
      expect do
        subject.human_to_machine_barcode(human_full)
      end.to raise_error, SBCF::InvalidBarcode
    end
  end

  # This doesn't quite match up with the true legacy behaviour
  # which raises ArgumentError if the barcode is too long
  # however there seems little point in reproducing that behaviour
  # precisely
  context 'with an invalid machine_barcode' do
    let(:ean13) { 45001057 }

    it 'number_to_human returns nil' do
      expect(subject.number_to_human(ean13)).to be_nil
    end

    it 'prefix_from_barcode returns nil' do
      expect(subject.prefix_from_barcode(ean13)).to be_nil
    end

    it 'barcode_to_human returns nil' do
      expect(subject.barcode_to_human(ean13)).to be_nil
    end
  end

  context 'which is too long' do
    let(:human_prefix) { 'PR' }
    let(:short_barcode) { 12345678 }

    it 'will raise an exception' do
      expect do
        subject.calculate_barcode(human_prefix, short_barcode)
      end.to raise_error ArgumentError
    end
  end
end
