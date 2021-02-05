# frozen_string_literal: true

#
# A simple class for calculating ean13 checksums
# This class is primarily intended for internal use
class Ean
  #
  # Calculate the Ean13 checksum for a provided code
  # @param code [Integer] The pre-ean13 machine barcode
  #
  # @return [Integer] The ean-13 checksum digit
  def self.calculate(code)
    new(code).to_i
  end

  #
  # Validate the checksum on a provided ean13 barcode
  # @param ean13 [Integer] Ean13 barcode
  #
  # @return [type] [description]
  def self.validate?(ean13)
    new(ean13, initial_weight: 1).to_i.zero?
  end

  #
  # Create an EAN
  # @param code [Integer] The code to calculate a checksum for
  # @param initial_weight: 3 [Integer] Used in the calculation.
  #         Set to 3 when calculating the ean, 1 when validating it Default: 3
  #
  # @return [type] [description]
  def initialize(code, initial_weight: 3)
    # The EAN is calculated by adding each digit modulo 10 ten weighted by 1 or 3 ( in seq)
    ean = 0
    weight = initial_weight
    while code.positive?
      code, c = code.divmod 10
      ean += c * weight % 10
      weight = weight == 1 ? 3 : 1
    end
    @ean = (10 - ean) % 10
  end

  def to_i
    @ean
  end
end
