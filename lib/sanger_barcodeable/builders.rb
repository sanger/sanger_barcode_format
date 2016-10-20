module SangerBarcodeable
  # Provide class methods to assist with creation of barcodes from
  # Different formats
  module Builders
    # Provide a human barcode eg. 'PR1234K' and returns a SangerBarcode object
    # checksum_required = set to true to reject barcodes without a checksum
    # Raises InvalidBarcode if the format doesn't match
    # raises ChecksumRequired if the checksum is missing, yet checksum_required is true
    def from_human(human_barcode,checksum_required=false)
      SangerBarcode.new(human_barcode:human_barcode,checksum_required:checksum_required)
    end

    # Provide a full 13 digit ean13 barcode and returns a SangerBarcode object
    # Raises InvalidBarcode if the barcode isn't 12-13 digits long
    def from_machine(machine_barcode)
      SangerBarcode.new(machine_barcode:machine_barcode)
    end

    def from_prefix_and_number(human_prefix,short_barcode)
      SangerBarcode.new(prefix:human_prefix,number:short_barcode)
    end
  end
end
