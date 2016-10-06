require 'sanger_barcodeable/shared_barcode'

module SangerBarcodeable
  class SangerBarcode
    include SharedBarcode

    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    def human_barcode
      @machine_barcode ||= calculate_human_barcode
    end

    def initialize(prefix,number,suffix=nil)
      @prefix = prefix.is_a?(String) ? Prefix.from_human(prefix) : prefix
      @number = number.to_i
      @suffix = suffix
    end

    def valid?
      @number.to_s.size <= 7
    end

  end
end
