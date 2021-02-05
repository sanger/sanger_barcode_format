# frozen_string_literal: true

module SBCF
  #
  # SBCF::EmptyBarcode is a convenience matcher for when you are explicitly
  # wanting to ensure that no user input (or an empty sting) is provided.
  # This ensures that SBCF::SangerBarcode entities with no content can remain
  # invalid, without being a special case. By explicitly requiring us to declare
  # we are expecting no content, it avoids odd behaviour when empty strings occur
  # unexpectedly.
  #
  class EmptyBarcode
    # String representation
    STRING_REP = '[empty]'
    #
    # Returns true only if passed an empty string or nil
    # @param other [nil, String] User input to validate if its blank
    #
    # @return [Boolean] true if the content is blank
    def =~(other)
      other.nil? || other.strip == ''
    end

    #
    # Returns true if the other element is also an empty barcode
    # @param other [Object] The object to match
    #
    # @return [Boolean] True is an empty barcode
    def ==(other)
      other.is_a?(EmptyBarcode)
    end

    #
    # Returns a string representation
    #
    # @return [String] [empty]
    def to_s
      STRING_REP
    end
  end
end
