# frozen_string_literal: true

module SBCF
  # These methods are all added to maintain compatibility with the
  # Existing sequencescape Barcode API. They will be deprecated over time.
  module LegacyMethods
    # Returns an array of [machine_prefix,number,machine_checksum]
    # You are encouraged to use the prefix, number and checksum methods instead
    # @deprecated You are encouraged to use the prefix, number and checksum methods instead
    # @param [String] machine_barcode Machine readable barcode
    # @return [Array] array of [machine_prefix:string, number:int, checksum:string]
    def split_barcode(machine_barcode)
      bc = SBCF::SangerBarcode.from_machine(machine_barcode)
      [bc.prefix.machine_s, bc.number, bc.checksum.machine]
    end

    # Returns an array of [human_prefix,number,human_checksum]
    # @deprecated You are encouraged to create and use a SangerBarcode instead
    # @param [String] code Human readable barcode
    # @return [Array] array of [human_prefix:string, number:string, checksum:string]
    def split_human_barcode(code)
      bc = SBCF::SangerBarcode.from_human(code)
      [bc.prefix.human, bc.number.to_s, bc.checksum.human]
    end

    # Extracts a barcode number from a machine readable barcode
    # @deprecated Use SBCF::SangerBarcode.from_machine(machine_barcode).number instead
    # @param [String] machine_barcode the machine readable barcode (eg. 4500001234757)
    # @return [String] The barcode number eg. 1234
    def number_to_human(machine_barcode)
      return nil if machine_barcode.nil?

      number = SBCF::SangerBarcode.from_machine(machine_barcode).number
      number&.to_s
    end

    # Returns the human readable prefix from a machine barcode
    # @deprecated Use SBCF::SangerBarcode.from_machine(machine_barcode).prefix.human instead
    # @param [String] machine_barcode the machine readable barcode (eg. 4500001234757)
    # @return [Sting] human readable prefix, eg. 'DN'
    def prefix_from_barcode(machine_barcode)
      barcode = SBCF::SangerBarcode.from_machine(machine_barcode)
      return nil unless barcode.valid?

      barcode.prefix.human
    end

    #
    # Convert a three digit machine prefix into a human readable two character prefix
    # eg. 122 into DN
    # @deprecated
    # @param [Integer] prefix The three digit integer at the beginning of the barcode. eg. 122
    # @return [String] The two character representation of the prefix eg. 'DN'
    #
    def prefix_to_human(prefix)
      Prefix.from_machine(prefix).human
    end

    #
    # Converts a full human barcode into an EAN13
    #
    # @param [String] human_barcode A full human readable barcode. eg. 'PR1234K'
    #
    # @return [Integer] An integer representation of the EAN13 barcode. eg. 4500001234757
    #
    def human_to_machine_barcode(human_barcode)
      bc = SBCF::SangerBarcode.from_human(human_barcode)
      raise InvalidBarcode, 'The human readable barcode was invalid, perhaps it was mistyped?' unless bc.valid?

      bc.machine_barcode
    end

    #
    # Converts the machine readable EAN13 into the human readable form
    # eg. barcode_to_human(4500001234757) => 'PR1234K'
    #
    # @param [Integer] code An integer representation of the EAN13 barcode. eg. 4500001234757
    #
    # @return [String]  A full human readable barcode. eg. 'PR1234K'
    #
    def barcode_to_human(code)
      SBCF::SangerBarcode.from_machine(code).human_barcode
    end

    #
    # Check that the ean checksum of the provided EAN13 barcoe is correct.
    #
    # @param [Int] code An integer representation of the EAN13 barcode. eg. 4500001234757
    #
    # @return [Bool] returns true if the checksum is correct
    #
    def check_ean(code)
      SBCF::SangerBarcode.from_machine(code).check_ean
    end
    alias check_EAN check_ean

    # Returns the Human barcode or raises an InvalidBarcode exception if there is a problem.  The barcode is
    # considered invalid if it does not translate to a Human barcode or, when the optional +prefix+ is specified,
    # its human equivalent does not match.
    def barcode_to_human!(code, prefix = nil)
      (barcode = SBCF::SangerBarcode.from_machine(code)) ||
        raise(InvalidBarcode, "Barcode #{code} appears to be invalid")
      unless prefix.nil? || (barcode.prefix.human == prefix)
        raise InvalidBarcode, "Barcode #{code} (#{barcode.human_barcode}) does not match prefix #{prefix}"
      end

      barcode.human_barcode
    end

    #
    # Returns an EAN13 barcode for the given prefix and number
    #
    # @param [String] human_prefix The two character human readable prefix. eg 'PR'
    # @param [Int] number The 1-7 digit barcode number. eg. 1234
    #
    # @return [Int] An integer representation of the EAN13 barcode. eg. 4500001234757
    #
    def calculate_barcode(human_prefix, number)
      SangerBarcode.new(prefix: human_prefix, number: number).machine_barcode
    end

    #
    # Returns the human redable checksum for the given prefix and number
    #
    # @param [String] human_prefix The two character human readable prefix. eg 'PR'
    # @param [Int] number The 1-7 digit barcode number. eg. 1234
    #
    # @return [String] The single character internal checksum. eg. 'K'
    #
    def calculate_checksum(human_prefix, number)
      SangerBarcode.new(prefix: human_prefix, number: number).checksum.human
    end
  end
end
