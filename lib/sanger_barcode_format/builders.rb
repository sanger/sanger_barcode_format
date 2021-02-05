# frozen_string_literal: true

module SBCF
  # Provide class methods to assist with creation of barcodes from
  # Different formats
  module Builders
    # Provide a human barcode eg. 'PR1234K' and returns a SangerBarcode object
    # checksum_required = set to true to reject barcodes without a checksum
    # Raises InvalidBarcode if the format doesn't match
    # raises ChecksumRequired if the checksum is missing, yet checksum_required is true
    #
    # @param human_barcode [String] A string representing the human readable barcode
    # @param checksum_required [Boolean] Set to true to enforce the presence of a checksum
    #
    # @return [SBCF::SangerBarcode] SangerBarcode representing the input string
    #
    def from_human(human_barcode, checksum_required: false)
      SangerBarcode.new(human_barcode: human_barcode, checksum_required: checksum_required)
    end

    # Provide a full 13 digit ean13 barcode and returns a SangerBarcode object
    #
    # @param machine_barcode [String] A string representing the ean13 formatted barcode
    #
    # @return [SBCF::SangerBarcode] SangerBarcode representing the input string
    #
    def from_machine(machine_barcode)
      SangerBarcode.new(machine_barcode: machine_barcode)
    end

    #
    # Generate an SBCF::SangerBarcode form a checksum and number
    # @param human_prefix [String] Two character prefix eg. DN
    # @param short_barcode [String] The 1-7 digit barcode number
    #
    # @return [SangerBarcode] A barcode object with the prefix and number provided
    def from_prefix_and_number(human_prefix, short_barcode)
      SangerBarcode.new(prefix: human_prefix, number: short_barcode)
    end

    #
    # Pass in a string that is either
    # - An ean13 barcode
    # - A human barcode with checksum
    # - A human barcode without checksum
    # @param input [String] A sanger format barcode, either in the human readable, or ean13 form
    #
    # @return [SangerBarcode] A barcode object corresponding to the provided text, or an invalid barcode
    #                         if the format does not match
    def from_user_input(input)
      case input.to_s
      when HUMAN_BARCODE_FORMAT
        SangerBarcode.new(human_barcode: input)
      when MACHINE_BARCODE_FORMAT
        SangerBarcode.new(machine_barcode: input)
      else
        SangerBarcode.new(human_barcode: '')
      end
    end
  end
end
