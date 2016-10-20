module SangerBarcodeable
  # These methods are all added to maintain compatibility with the
  # Existing sequencescape Barcode API. They will be deprecated over time.
  module LegacyMethods

    def split_barcode(code)
      SangerBarcodeable::SangerBarcode.from_machine(code).split_barcode
    end

    def split_human_barcode(code)
      SangerBarcodeable::SangerBarcode.from_human(code).split_human_barcode
    end

    def number_to_human(machine_barcode)
      begin
        SangerBarcodeable::SangerBarcode.from_machine(machine_barcode).number.to_s
      rescue InvalidBarcode
        # Catching exceptions to preseve old behaviour
        nil
      end
    end

    def prefix_from_barcode(machine_barcode)
      begin
        SangerBarcodeable::SangerBarcode.from_machine(machine_barcode).prefix.human
      rescue InvalidBarcode
        # Catching exceptions to preseve old behaviour
        nil
      end
    end

    def prefix_to_human(prefix)
      Prefix.from_machine(prefix).human
    end

    def human_to_machine_barcode(human_barcode)
      bc = SangerBarcodeable::SangerBarcode.from_human(human_barcode)
      unless bc.valid?
        raise InvalidBarcode, "The human readable barcode was invalid, perhaps it was mistyped?"
      end
      bc.machine_barcode
    end

    def barcode_to_human(code)
      begin
        SangerBarcodeable::SangerBarcode.from_machine(code).human_barcode
      rescue InvalidBarcode
        # Catching exceptions to preseve old behaviour
        nil
      end
    end

    def check_EAN(code)
      SangerBarcodeable::SangerBarcode.from_machine(code).check_EAN
    end

    # Returns the Human barcode or raises an InvalidBarcode exception if there is a problem.  The barcode is
    # considered invalid if it does not translate to a Human barcode or, when the optional +prefix+ is specified,
    # its human equivalent does not match.
    def barcode_to_human!(code, prefix = nil)
      barcode = SangerBarcodeable::SangerBarcode.from_machine(code) or raise InvalidBarcode, "Barcode #{ code } appears to be invalid"
      unless prefix.nil? or barcode.prefix.human == prefix
        raise InvalidBarcode, "Barcode #{ code } (#{ barcode.human_barcode }) does not match prefix #{ prefix }"
      end
      barcode.human_barcode
    end

    def calculate_barcode(human_prefix, number)
      SangerBarcode.new(prefix:human_prefix,number:number).machine_barcode
    end

    def calculate_checksum(human_prefix, number)
      SangerBarcode.new(prefix:human_prefix,number:number).checksum.human
    end
  end
end
