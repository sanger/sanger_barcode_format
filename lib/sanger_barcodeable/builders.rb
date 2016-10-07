module SangerBarcodeable
  # Provide class methods to assist with creation of barcodes from
  # Different formats
  module Builders
    # Provide a human barcode eg. 'PR1234K' and returns a SangerBarcode object
    # checksum_required = set to true to reject barcodes without a checksum
    # Raises InvalidBarcode if the format doesn't match
    # raises ChecksumRequired if the checksum is missing, yet checksum_required is true
    def from_human(human_barcode,checksum_required=false)
      match = HumanBarcodeFormat.match(human_barcode)
      raise InvalidBarcode, "The human readable barcode was invalid, perhaps it was mistyped?" if match.nil?
      human_prefix = match[1]
      short_barcode = match[2]
      checksum = match[3]
      raise ChecksumRequired, "You must supply a complete barcode, including the final letter (eg. DN12345R)." if checksum_required && checksum.nil?
      SangerBarcode.new(human_prefix,short_barcode,checksum:checksum)
    end

    # Provide a full 13 digit ean13 barcode and returns a SangerBarcode object
    # Raises InvalidBarcode if the barcode isn't 12-13 digits long
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
end
