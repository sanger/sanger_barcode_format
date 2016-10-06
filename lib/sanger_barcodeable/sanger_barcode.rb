require 'sanger_barcodeable/shared_barcode'

module SangerBarcodeable
  class SangerBarcode

    HumanBarcodeFormat = /\A([A-Z]{2})(\d{1,7})([A-Z]{0,1}\z)/
    MachineBarcodeFormat = /\A([0-9]{3})([0-9]{7})([0-9]{2})([0-9]{1})\z/

    module Builders

      def from_human(human_barcode,checksum_required=false)
        match = HumanBarcodeFormat.match(human_barcode)
        raise InvalidBarcode, "The human readable barcode was invalid, perhaps it was mistyped?" if match.nil?
        human_prefix = match[1]
        short_barcode = match[2]
        checksum = match[3]
        raise SuffixRequired, "You must supply a complete barcode, including the final letter (eg. DN12345R)." if checksum_required && checksum.nil?
        SangerBarcode.new(human_prefix,short_barcode,checksum:checksum)
      end

      def from_machine(machine_barcode)
        machine_barcode_string = machine_barcode.to_s

        # Prefixes of CR or lower result in an ean13 that begins with 0. In some cases,
        # this digit gets stripped, and a 12-digit long UPC-A is returned instead. This
        # is partly due to cases where we convert the ean13 to an integer, but also extends
        # to physical labels and their subsequent scanning.
        machine_barcode_string = machine_barcode_string.rjust(13,'0') if machine_barcode_string.length == 12

        match = MachineBarcodeFormat.match(machine_barcode_string)
        raise InvalidBarcode, "#{machine_barcode} is not a valid ean13 barcode" if match.nil?
        full, prefix, number, checksum, check = *match
        SangerBarcode.new(Prefix.from_machine(prefix),number,machine_barcode:machine_barcode)
      end

      def from_prefix_and_number(human_prefix,short_barcode)
        SangerBarcode.new(human_prefix,short_barcode)
      end
    end

    extend Builders
    include SharedBarcode

    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    def human_barcode
      @machine_barcode ||= calculate_human_barcode
    end

    def initialize(prefix,number,checksum: nil,machine_barcode: nil)
      @prefix = prefix.is_a?(Prefix) ? prefix : Prefix.from_human(prefix)
      @number = number.to_i
      @checksum = Checksum.from_human(checksum) if checksum
      @provided_machine_barcode = machine_barcode.to_i if machine_barcode
    end

    def valid?
      @number.to_s.size <= NUMBER_LENGTH &&
      calculate_checksum == checksum.human
    end

  end
end
