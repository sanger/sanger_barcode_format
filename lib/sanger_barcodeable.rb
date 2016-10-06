require "sanger_barcodeable/version"
require "sanger_barcodeable/legacy_methods"
require "sanger_barcodeable/prefix"

module SangerBarcodable
  module Barcode

    BarcodeError= Class.new(StandardError)
    InvalidBarcode = Class.new(BarcodeError)
    SuffixRequired = Class.new(BarcodeError)
    InvalidBarcodeOperation = Class.new(BarcodeError)

    HumanBarcodeFormat = /\A(\w{2})(\d{1,7})(\w{0,1}\z)/
    MachineBarcodeFormat = /\A([0-9]{3})([0-9]{7})([0-9]{2})([0-9]{1})\z/

    def self.from_human(human_barcode,suffix_required=false)
      match = HumanBarcodeFormat.match(human_barcode)
      raise InvalidBarcode, "The human readable barcode was invalid, perhaps it was mistyped?" if match.nil?
      human_prefix = match[1]
      short_barcode = match[2]
      suffix = match[3]
      raise SuffixRequired, "You must supply a complete barcode, including the final letter (eg. DN12345R)." if suffix_required && suffix.nil?
      SangerBarcode.new(human_prefix,short_barcode,suffix)
    end

    def self.from_machine(machine_barcode)
      machine_barcode_string = machine_barcode.to_s

      # Prefixes of CR or lower result in an ean13 that begins with 0. In some cases,
      # this digit gets stripped, and a 12-digit long UPC-A is returned instead. This
      # is partly due to cases where we convert the ean13 to an integer, but also extends
      # to physical labels and their subsequent scanning.
      machine_barcode_string = machine_barcode_string.rjust(13,'0') if machine_barcode_string.length == 12

      match = MachineBarcodeFormat.match(machine_barcode_string)
      raise InvalidBarcode, "#{machine_barcode} is not a valid ean13 barcode" if match.nil?
      full, prefix, number, suffix, check = *match
      MachineBarcode.new(machine_barcode_string)
      SangerBarcode.new(Prefix.from_machine(prefix),number)
    end

    def self.from_prefix_and_number(human_prefix,short_barcode)
      SangerBarcode.new(human_prefix,short_barcode)
    end


    extend LegacyMethods

  end
end

require "sanger_barcodeable/classes_to_organize"
