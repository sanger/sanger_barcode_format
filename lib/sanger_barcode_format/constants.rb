# frozen_string_literal: true

module SBCF
  # Subtracted from prefixes byte values during conversion to numbers
  # Results in A having a value of 1
  ASCII_OFFSET = 64
  # Used in calculating the prefix. Multiplies the first character in
  # our two byte prefix essentially defining our base.
  # Note: The use of base27 results in a two digit increase between
  # AZ and BA. This behaviour was in the original implementation and
  # has been maintained for reasons of compatibility. I am not aware
  # of the original reasons for the decision.
  PREFIX_BASE = 27
  PREFIX_LENGTH = 3 # The digit length of the numeric encoded checksum
  NUMBER_LENGTH = 7 # The digit length of the unique barcode number
  CHECKSUM_LENGTH = 2 # The digit length of the internal checksum

  # The length of the internally generated portion of the barcode
  # This ignores the print checksum which is internal to the ean13 standard
  INTERNAL_LENGTH = PREFIX_LENGTH + NUMBER_LENGTH + CHECKSUM_LENGTH

  # The checksum uses a 0 indexed checksum
  CHECKSUM_ASCII_OFFSET = 65

  # Regex to match human readable barcodes eg. PR1234K
  # Matches 1: prefix, 2: number, 3: checksum/suffix (optional)
  HUMAN_BARCODE_FORMAT = /\A(?<prefix>[A-Z]{2})(?<number>\d{1,7})(?<checksum>[A-Z]{0,1}\z)/.freeze

  # Regex to match the full ean13 barcode, including all checksums
  # The { 2,3 } prefix matcher ensures that any barcodes beginning
  # with zero are correctly parsed, even if the zero is stripped.
  # Matches 1: Prefix, 2: number 3: suffix 4: ean
  MACHINE_BARCODE_FORMAT = /\A(\d{2,3})(\d{7})(\d{2})(\d{1})\z/.freeze
end
