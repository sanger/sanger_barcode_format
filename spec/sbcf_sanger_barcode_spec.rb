require 'sanger_barcode_format'
require 'spec_helper'

shared_examples_for 'a valid SangerBarcode instance' do
  let(:other_barcode) { SBCF::SangerBarcode.new(prefix: human_prefix, number: short_barcode) }

  it '#human_full returns the full human barcode' do
    expect(subject.human_barcode).to eq(human_full)
  end
  it '#machine_barcode returns the ean13 barcode' do
    expect(subject.machine_barcode).to eq(ean13)
  end
  it '#valid? is true' do
    expect(subject).to be_valid
  end
  it 'is equal to equivalent barcodes' do
    expect(subject).to eq(other_barcode)
  end
  # If you want to compare strings, use the match operators, or ~=
  it 'is not equal to human barcode strings' do
    expect(subject).not_to eq(human_full)
  end
  it 'is not equal to ean13 strings' do
    expect(subject).not_to eq(ean13)
  end
  it 'is =~ to equivalent barcodes' do
    expect(subject =~ other_barcode).to be true
  end
  it 'is =~ to human barcode string' do
    expect(subject =~ human_full).to be true
  end
  it 'is =~ to human ean13 strings' do
    expect(subject =~ ean13).to be true
  end

  it 'converts to a string' do
    expect(subject.to_s).to eq("#{human_full} (#{ean13})")
  end
end

shared_examples_for 'an invalid SangerBarcode instance' do
  subject { SBCF::SangerBarcode }

  it 'is invalid from human' do
    expect(subject.from_human(human_full)).to_not be_valid
  end

  it 'it is invalid from machine' do
    expect(subject.from_machine(ean13)).to_not be_valid
  end

  it 'converts to a string' do
    expect(subject.from_human(human_full).to_s).to eq('[invalid format]')
  end
end

shared_examples_for 'a modern barcode' do
  subject { SBCF::SangerBarcode }

  describe '::from_human' do
    subject { described_class.from_human(input) }

    context 'with a full human barcode' do
      let(:input) { human_full }
      it_behaves_like 'a valid SangerBarcode instance'
    end

    context 'with a short human barcode' do
      let(:input) { human_short }
      it_behaves_like 'a valid SangerBarcode instance'
    end
  end

  describe '::from_machine' do
    subject { described_class.from_machine(input) }

    context 'with an ean13' do
      let(:input) { ean13 }
      it_behaves_like 'a valid SangerBarcode instance'
    end
  end

  describe '::from_user_input' do
    subject { described_class.from_user_input(input) }

    context 'with a full human barcode' do
      let(:input) { human_full }
      it_behaves_like 'a valid SangerBarcode instance'
    end

    context 'with a short human barcode' do
      let(:input) { human_short }
      it_behaves_like 'a valid SangerBarcode instance'
    end

    context 'with an ean13' do
      let(:input) { ean13 }
      it_behaves_like 'a valid SangerBarcode instance'
    end
  end

  describe '::from_prefix_and_number' do
    subject { described_class.from_prefix_and_number(*input) }
    context 'with a prefix and number' do
      let(:input) { [human_prefix, short_barcode] }
      it_behaves_like 'a valid SangerBarcode instance'
    end
  end
end

describe SBCF::SangerBarcode do
  context 'with valid parameters' do
    let(:human_prefix) { 'PR' }
    let(:human_checksum) { 'K' }
    let(:human_full) { 'PR1234K' }
    let(:human_short) { 'PR1234' }
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
    let(:human_short) { 'BD1' }
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

    it_behaves_like 'an invalid SangerBarcode instance'
  end

  context 'which is too long' do
    let(:human_prefix) { 'PR' }
    let(:human_full) { 'PR12345678' }
    let(:ean13) { 4500101234757 }

    let(:short_barcode) { 12345678 }
    it_behaves_like 'an invalid SangerBarcode instance'
  end

  context 'handling empty and invalid input' do
    let(:barcode_from_empty_input) { described_class.from_user_input(empty_input) }
    let(:barcode_from_invalid_input) { described_class.from_user_input(invalid_input) }
    let(:empty_input) { '' }
    let(:invalid_input) { 'NOT_VALID' }

    # Empty barcode are NOT treated as a special case of invalid barcode.
    # While there are situations in which we may be matching 'no barcode' to
    # 'no barcode' (such as in bed verification, ensuring empty beds) this situation
    # should be handled explicitly.
    # The SBCF::EmptyBarcode is provided for this situation
    context 'an empty barcode' do
      it 'doesn\'t equal empty input' do
        expect(barcode_from_empty_input).not_to eq barcode_from_empty_input
      end
      it '=~ empty input' do
        expect(barcode_from_empty_input =~ empty_input).to be false
      end
      it "doesn't =~ invalid input" do
        expect(barcode_from_empty_input =~ invalid_input).to be false
      end
    end

    context 'an invalid barcode' do
      it 'doesn\'t equal empty input' do
        expect(barcode_from_invalid_input).not_to eq barcode_from_empty_input
      end
      it 'doesn\'t =~ empty input' do
        expect(barcode_from_invalid_input =~ empty_input).to be false
      end
      it "doesn't =~ invalid input" do
        expect(barcode_from_invalid_input =~ invalid_input).to be false
      end
    end
  end
end

describe SBCF::SangerBarcode do
end
