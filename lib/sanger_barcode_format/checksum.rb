# frozen_string_literal: true

module SBCF
  ##
  # Checsum is an internally generated checksum used to validate
  # user typed barcodes. In human readable format is consists of a
  # single letter, in machine readable form, two digits. It appears
  # at the end of the barcode.
  class Checksum
    # Generate a Checksum from the single letter human form
    #
    # @param [String] human_checksum A single letter representing the human readable checksum
    # @return [Checksum] A new checksum object
    def self.from_human(human_checksum)
      new(human_checksum: human_checksum)
    end

    # Generate a Checksum from the two digit machine form
    #
    # @param [Int] machine_checksum two digit integer representing the machine readable checksum
    # @return [Type] A new checksum object
    def self.from_machine(machine_checksum)
      new(machine_checksum: machine_checksum)
    end

    # Generate a checksum from the barcode prefix and number
    #
    # @param [Prefix] prefix a barcode prefix object
    # @param [Int] number The barcode number
    # @return [Checksum] Corresponding checksum object
    def self.from_prefix_and_number(prefix, number)
      string = prefix.human + number.to_s
      list = string.reverse
      sum = 0
      list.bytes.each_with_index do |byte, i|
        sum += byte * (i + 1)
      end
      new(human_checksum: (sum % 23 + CHECKSUM_ASCII_OFFSET).chr)
    end

    # Create a new checksum from either the huamn or machine form
    #
    # @param [String] human_checksum A single letter representing the human readable checksum
    # @param [Int] machine_checksum  Two digit integer representing the machine readable checksum
    # @return [Checksum] A new checksum object
    def initialize(human_checksum: nil, machine_checksum: nil)
      raise BarcodeError, 'Must supply a human or machine checksum' unless human_checksum || machine_checksum

      @human = human_checksum
      @machine = machine_checksum.to_i if machine_checksum
    end

    # Return the machine readable checksum
    #
    # @return [Int] Two digit integer representing the machine readable checksum
    def machine
      @machine ||= human.getbyte(0)
    end

    # Return the human readable checksum
    #
    # @return [String] A single letter representing the human readable checksum
    def human
      @human ||= @machine.chr
    end

    # Returns ture if the checksums match
    # Checsums match if their value is the same, regardless of how they were
    # calculated.
    #
    # @param [Checksum] other the checksum with which to compare
    # @return [Bool] description tru is the checsums match, false otherwise
    def ==(other)
      raise ArgumentError, 'Can only compare a checksum with a checksum' unless other.is_a?(Checksum)

      human == other.human
    end
  end
end
