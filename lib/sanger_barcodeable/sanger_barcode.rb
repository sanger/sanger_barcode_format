require 'sanger_barcodeable/shared_barcode'
require 'sanger_barcodeable/builders'

module SangerBarcodeable
  class SangerBarcode

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
