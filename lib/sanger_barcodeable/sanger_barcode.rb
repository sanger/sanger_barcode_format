require 'sanger_barcodeable/builders'

module SangerBarcodeable
  class SangerBarcode
    attr_reader :prefix, :number, :checksum
    extend Builders

    # Returns the machine readable ean13
    #
    # @return [Int] The machine readable ean13 barcode
    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    # Returns the human readable barcode
    #
    # @return [String] eg. DN12345R
    def human_barcode
      @human_barcode ||= calculate_human_barcode
    end

    # Returns the internally used checksum
    #
    # @return [SangerBarcodeable::Checksum] The internally used checksum
    def checksum
      @checksum ||= Checksum.from_human(calculate_checksum)
    end

    # Create a new barcode object.
    # Either:
    # - Provide a prefix and number
    # - Provide a machine barcode (Ean13)
    # - Provide a human readable barcode (Eg. DN12345) If checksum required is set to true will raise ChecksumRequired
    #   if the internal checksum character is missing.
    #
    # @param [String||SangerBarcodable::Prefix] prefix:nil The two letter prefix or a Prefix object
    # @param [Int] number:nil The unique number, up to 7 digits long
    # @param [String] checksum:nil Optional human readable checksum character.
    # @param [Sting||Int] machine_barcode:nil Ean13 barcode as red by a scanner
    # @param [String] human_barcode:nil Human readable barcode eg. DN12345R
    # @param [Bool] checksum_required:false If set to true will enforce presence of checksum on human_barcode input
    # @return [SangerBarcodable::SangerBarcode] A representation of the barcode
    def initialize(
      prefix: nil, number: nil, checksum: nil,
      machine_barcode: nil,
      human_barcode: nil, checksum_required: false
    )
      argument_error! unless [(prefix && number), machine_barcode, human_barcode].one?

      self.prefix = prefix
      self.number = number
      self.checksum = checksum
      self.machine_barcode = machine_barcode.to_i if machine_barcode
      @checksum_required = checksum_required
      self.human_barcode = human_barcode if human_barcode
    end

    # Checks is the data provided generate a valid barcode
    # - The number is in the correct range
    # - Any provided checksum is correct
    # - Any provided EAN is correct
    # @return [Bool] true is the barode is valid, false otherwise
    def valid?
      number.to_s.size <= NUMBER_LENGTH &&
        calculate_checksum == checksum.human &&
        check_ean
    end

    # Checks that the EAN digit of the provided machine barcode is correct
    # In practice this should be enforced by the scanners, so should only be
    # false is the data were input manually
    #
    # @return [Bool] true if the EAN is valid, or the barcode was not a machine barcode originally
    def check_ean
      # the EAN checksum is calculated so that the EAN of the code with checksum added is 0
      # except the new column (the checksum) start with a different weight (so the previous column keep the same weight)
      @machine_barcode.nil? || calculate_ean(@machine_barcode, 1).zero?
    end

    ####### PRIVATE METHODS ###################################################################
    private

    def prefix=(prefix)
      return if prefix.nil?
      @prefix = prefix.is_a?(Prefix) ? prefix : Prefix.from_human(prefix)
    end

    def number=(number)
      @number = number && number.to_i
    end

    def checksum=(checksum)
      @checksum = checksum && Checksum.from_human(checksum)
    end

    # Used internally during barcode creation. Takes a machine barcode and
    # splits it into is component parts
    #
    # @param [String||Int] The 13 digit long ean13 barcode
    # @return [String||Int] Returns the input
    def machine_barcode=(machine_barcode)
      @machine_barcode = machine_barcode.to_i
      match = MachineBarcodeFormat.match(machine_barcode.to_s)
      raise InvalidBarcode, "#{machine_barcode} is not a valid ean13 barcode" if match.nil?
      set_from_machine_components(*match)
      machine_barcode
    end

    def set_from_machine_components(_full, prefix, number, _checksum, _check)
      @prefix = Prefix.from_machine(prefix)
      @number = number.to_i
    end

    def human_barcode=(human_barcode)
      match = HumanBarcodeFormat.match(human_barcode)
      raise InvalidBarcode, 'The human readable barcode was invalid, perhaps it was mistyped?' if match.nil?
      human_prefix = match[1]
      short_barcode = match[2]
      checksum = match[3]

      if @checksum_required && checksum.nil?
        raise ChecksumRequired, 'You must supply a complete barcode, including the final letter (eg. DN12345R).'
      end

      @prefix = Prefix.from_human(human_prefix)
      @number = short_barcode.to_i
      @checksum = Checksum.from_human(checksum) if checksum
    end

    def calculate_ean13(code)
      calculate_ean(code)
    end

    def calculate_ean(code, initial_weight = 3)
      # The EAN is calculated by adding each digit modulo 10 ten weighted by 1 or 3 ( in seq)
      ean = 0
      weight = initial_weight
      while code > 0
        code, c = code.divmod 10
        ean += c * weight % 10
        weight = weight == 1 ? 3 : 1
      end
      (10 - ean) % 10
    end

    def calculate_checksum
      string = prefix.human + number.to_s
      list = string.reverse
      sum = 0
      list.bytes.each_with_index do |byte, i|
        sum += byte * (i + 1)
      end
      (sum % 23 + CHECKSUM_ASCII_OFFSET).chr
    end

    # Returns the full length machine barcode
    def calculate_machine_barcode
      sanger_barcode * 10 + calculate_ean13(sanger_barcode)
    end

    def calculate_human_barcode
      "#{prefix.human}#{number}#{checksum.human}" if valid?
    end

    # Returns the machine barcode minus the EAN13 print checksum.
    def sanger_barcode
      raise ArgumentError, "Number : #{number} to big to generate a barcode." if number.to_s.size > 7
      prefix.machine_full + (number * 100) + calculate_checksum.getbyte(0)
    end

    def argument_error!
      raise ArgumentError, 'You must provide either a prefix and a number, or a human or machine barcode'
    end
  end
end
