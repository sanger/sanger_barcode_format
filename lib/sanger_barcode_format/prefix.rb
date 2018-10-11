module SBCF
  # Prefixes are found at the front of sanger_barcodable_spec
  # They have a two character human form, or a three digit machine form
  class Prefix
    # Create a prefix object from the character string
    #
    # @param [Sting] human_prefix A two character prefix (eg. DN)
    # @return [Prefix] A new instance of the prefix class
    def self.from_human(human_prefix)
      new(human_prefix: human_prefix)
    end

    # Create a prefix object from the digit representation
    #
    # @param [Int] machine_prefix A two-three digit prefix (eg. 122)
    # @return [Prefix] A new instance of the prefix class
    def self.from_machine(machine_prefix)
      new(machine_prefix: machine_prefix)
    end

    def self.from_input(prefix)
      return prefix if prefix.is_a?(Prefix)
      Prefix.from_human(prefix)
    end

    # Return a new instance of the prefix class, either from the supplier
    # human_prefix or supplief machine_prefix
    #
    # @param [String] human_prefix A two character prefix (eg. DN)
    # @param [Int] machine_prefix A two-three digit prefix (eg. 122)
    # @return [Prefix] A new instance of the prefix class
    def initialize(human_prefix: nil, machine_prefix: nil)
      raise BarcodeError, 'Must supply a human or machine prefix' unless human_prefix || machine_prefix
      @human = human_prefix
      @machine = machine_prefix.to_i if machine_prefix
    end

    # Returns the 3 digit encoded prefix as used in barcodes
    #
    # @return [Int] A two - three digit prefix (eg. 122)
    def machine
      @machine ||= calculate_machine
    end

    # Returns the 3 digit encoded prefix as used in barcodes (zero padded)
    #
    # @return [String] A zero padded three digit prefix (eg. 122)
    def machine_s
      machine_s = machine.to_s
      padding = above_zero(PREFIX_LENGTH - machine_s.length)
      machine_s.insert(0, '0' * padding)
    end

    # A two character prefix (eg. DN)
    #
    # @return [String] A two character prefix (eg. DN)
    def human
      @human ||= calculate_human
    end

    # Returns the prefix mutliplied to allow addition of the numeric form
    # @deprecated This method will be made private in future versions
    # @return [Int] barcode prefix multipled by 10000000
    def machine_full
      machine * 10**(NUMBER_LENGTH + CHECKSUM_LENGTH)
    end

    private

    def calculate_machine
      first  = above_zero(human.getbyte(0) - ASCII_OFFSET)
      second = above_zero(human.getbyte(1) - ASCII_OFFSET)
      ((first * PREFIX_BASE) + second)
    end

    def calculate_human
      ((machine / PREFIX_BASE) + ASCII_OFFSET).chr + ((machine % PREFIX_BASE) + ASCII_OFFSET).chr
    end

    # Avoid needlessly creating an array
    def above_zero(value)
      value < 0 ? 0 : value
    end
  end
end
