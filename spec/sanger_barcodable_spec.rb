require 'sanger_barcodeable'
require 'spec_helper'

shared_examples_for "a barcode" do


  it "calculates the full barcode" do
    SangerBarcodable::Barcode.calculate_barcode(human_prefix,short_barcode).should eq(ean13)
  end

  it "calculates a checksum" do
    SangerBarcodable::Barcode.calculate_checksum(human_prefix,short_barcode).should eq(human_checksum)
  end

  it "splits a barcode into its components" do
    # Seems wrong, why is machine prefix a string, but the rest integers?
    SangerBarcodable::Barcode.split_barcode(ean13).should eq([machine_prefix_s,short_barcode,machine_checksum])
  end

  it "splits a human barcode into its components" do
    SangerBarcodable::Barcode.split_human_barcode(human_full).should eq([human_prefix,short_barcode.to_s,human_checksum])
  end

  it "converts machine_barcodes to human" do
    # This method seems badly named to me. Human implies the full 'PR1234K' barcode, not just
    # the short 'barcode' number as stored in the database.
    SangerBarcodable::Barcode.number_to_human(ean13).should eq(short_barcode.to_s)
  end

  it "gets the human prefix from the ean13 barcode" do
    SangerBarcodable::Barcode.prefix_from_barcode(ean13).should eq(human_prefix)
  end

  it "can convert numeric prefixes to human" do
    SangerBarcodable::Barcode.prefix_to_human(machine_prefix_i).should eq(human_prefix)
  end

  it "can convert between human barcodes and machine barcodes" do
    SangerBarcodable::Barcode.human_to_machine_barcode(human_full).should eq(ean13)
    SangerBarcodable::Barcode.barcode_to_human(ean13).should eq(human_full)
  end

  it "can convert to human barcodes with a prefix check" do
    SangerBarcodable::Barcode.barcode_to_human!(ean13, human_prefix).should eq(human_full)
    expect {
      SangerBarcodable::Barcode.barcode_to_human!(ean13, 'XX')
    }.to raise_error
  end

  it "has a vaild ean13" do
    SangerBarcodable::Barcode.check_EAN(ean13).should eq(true)
  end

  it "can freely convert between them using the new models" do
    SangerBarcodable::Barcode.from_human(human_full).human_barcode.should eq(human_full)
    SangerBarcodable::Barcode.from_human(human_full).machine_barcode.should eq(ean13)
    SangerBarcodable::Barcode.from_machine(ean13).human_barcode.should eq(human_full)
    SangerBarcodable::Barcode.from_machine(ean13).machine_barcode.should eq(ean13)
    SangerBarcodable::Barcode.from_prefix_and_number(human_prefix,short_barcode).human_barcode.should eq(human_full)
    SangerBarcodable::Barcode.from_prefix_and_number(human_prefix,short_barcode).machine_barcode.should eq(ean13)
  end

  # This method doesn't appear to be used externally, only in barcode generation
  # it "can find an ean13" do
  #   SangerBarcodable::Barcode.calculate_EAN13(pre_ean13).should eq(print_checksum)
  # end
end

describe SangerBarcodable::Barcode do

  context "with valid parameters" do

    let (:human_prefix) {'PR'}
    let (:human_checksum) {'K'}
    let (:human_full) {'PR1234K'}
    let (:short_barcode) {1234}

    let (:machine_prefix_s) {'450'}
    let (:machine_prefix_i) { 450 }
    let (:ean13) {4500001234757}
    let (:pre_ean13) {450000123475}
    let (:machine_checksum) {75}
    let (:print_checksum) {7}

    it_behaves_like "a barcode"
  end


  context "with low prefix parameters" do

    let (:human_prefix) {'BD'}
    let (:human_checksum) {'P'}
    let (:human_full) {'BD1P'}
    let (:short_barcode) {1}

    let (:machine_prefix_s) {'058'}
    let (:machine_prefix_i) { 58 }
    let (:ean13) {580000001806}
    let (:pre_ean13) {58000000180}
    let (:machine_checksum) {80}
    let (:print_checksum) {8}

    it_behaves_like "a barcode"
  end

  context "with invalid parameters" do

    let (:human_prefix) {'XX'}
    let (:human_checksum) {'X'}
    let (:human_full) {'XX1234X'}
    let (:short_barcode) {1234}

    let (:machine_prefix) {450}
    let (:ean13) {4500101234757}
    let (:pre_ean13) {450010123475}
    let (:machine_checksum) {75}
    let (:print_checksum) {7}

    it "has a invaild ean13" do
      SangerBarcodable::Barcode.check_EAN(ean13).should eq(false)
    end

    it "will raise on conversion" do
      expect {
        SangerBarcodable::Barcode.barcode_to_human!(ean13, 'XX')
      }.to raise_error
      expect {
        SangerBarcodable::Barcode.human_to_machine_barcode(human_full)
      }.to raise_error
    end

  end

  context "which is too long" do
    let (:human_prefix) {'PR'}
    let (:short_barcode) {12345678}

    it "will raise an exception" do
      expect {
        SangerBarcodable::Barcode.calculate_barcode(human_prefix,short_barcode)
      }.to raise_error
    end
  end

end

