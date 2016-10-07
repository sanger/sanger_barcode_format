require 'sanger_barcodeable/builders'

module SangerBarcodeable
  class SangerBarcode

    attr_reader :prefix, :number

    extend Builders

    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    def human_barcode
      @machine_barcode ||= calculate_human_barcode
    end

    def initialize(prefix,number,checksum: nil,machine_barcode: nil)
      @prefix = prefix.is_a?(Prefix) ? prefix : Prefix.from_human(prefix)
      @number = number.to_i
      @checksum = Checksum.from_human(checksum) if checksum
      @provided_machine_barcode = machine_barcode.to_i if machine_barcode
    end

    def valid?
      @number.to_s.size <= NUMBER_LENGTH &&
      calculate_checksum == checksum.human
    end

    def checksum
      return @checksum unless @checksum.nil?
      @checksum = Checksum.from_human(calculate_checksum)
    end

    def check_EAN
      #the EAN checksum is calculated so that the EAN of the code with checksum added is 0
      #except the new column (the checksum) start with a different weight (so the previous column keep the same weight)
      calculate_EAN(@provided_machine_barcode, 1) == 0
    end

    # Legacy methods
    def split_human_barcode
      [prefix.human,number.to_s,checksum.human]
    end

    def split_barcode
      [prefix.machine_s,number,checksum.machine]
    end

    ####### PRIVATE METHODS ###################################################################
    private

    def calculate_EAN13(code)
      calculate_EAN(code)
    end

    def calculate_EAN(code, initial_weight=3)
      #The EAN is calculated by adding each digit modulo 10 ten weighted by 1 or 3 ( in seq)
      ean = 0
      weight = initial_weight
      while code >0
        code, c = code.divmod 10
        ean += c*weight % 10
        weight = weight == 1 ? 3 : 1
      end
      (10 -ean) % 10
    end

    def calculate_checksum
      string = prefix.human + number.to_s
      list = string.reverse
      sum = 0
      list.bytes.each_with_index do |byte,i|
        sum += byte * (i+1)
      end
      (sum % 23 + CHECKSUM_ASCII_OFFSET).chr
    end

    # Returns the full length machine barcode
    def calculate_machine_barcode
      sanger_barcode*10+calculate_EAN13(sanger_barcode)
    end

    def calculate_human_barcode
      "#{prefix.human}#{number.to_s}#{checksum.human}" if valid?
    end

    # Returns the machine barcode minus the EAN13 print checksum.
    def sanger_barcode
      raise ArgumentError, "Number : #{number} to big to generate a barcode." if number.to_s.size > 7
      prefix.machine_full + (number * 100) + calculate_checksum.getbyte(0)
    end

  end
end
