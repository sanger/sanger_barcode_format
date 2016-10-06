# This is a temporary storage space while I refactor
module SangerBarcodable
  class Checksum

    def self.from_human(human_checksum)
      new(human_checksum,nil)
    end

    def self.from_machine(machine_checksum)
      new(nil,machine_checksum)
    end

    def initialize(human_checksum,machine_checksum=nil)
      raise BarcodeError, 'Must supply a human or machine checksum' unless human_checksum||machine_checksum
      @human = human_checksum
      @machine = machine_checksum.to_i if machine_checksum
    end

    def machine
      @machine ||= human[0]
    end

    def human
      @human ||= @machine.chr
    end
  end

  module SharedBarcode

    # Accessors
    def prefix
      return @prefix unless @prefix.nil?
      parse_barcode
      @prefix
    end

    def number
      return @number unless @number.nil?
      parse_barcode
      @number
    end

    def checksum
      return @checksum unless @checksum.nil?
      parse_barcode
      @checksum
    end

    def check_EAN
      #the EAN checksum is calculated so that the EAN of the code with checksum added is 0
      #except the new column (the checksum) start with a different weight (so the previous column keep the same weight)
      calculate_EAN(machine_barcode, 1) == 0
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
    def parse_barcode
      code = machine_barcode.to_s
      # Maintaining compatability here, but this line just seems weird.
      # I think the intent is to pad out barcodes lacking a print checksum
      # but if this is the case the 0 is added to the wrong end
      code = code.rjust(13,'0') if code.size == 12
      if /^(...)(.*)(..).$/ =~ code
        @prefix ||= Prefix.from_machine($1)
        @number ||= $2.to_i
        @checksum ||= Checksum.from_machine($3.to_i)
      else
        raise InvalidBarcode, "The barcode #{code} is not in the expected format."
      end
    end

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
      list = string.reverse.chars
      sum = 0
      list.each_with_index do |character,i|
        sum += character[0] * (i+1)
      end
      (sum % 23 + "A"[0]).chr
    end

    def calculate_machine_barcode
      calculate_barcode
    end

    def calculate_human_barcode
      "#{prefix.human}#{number.to_s}#{checksum.human}" if valid?
    end

    def calculate_barcode
      # Returns the full length machine barcode
      barcode = sanger_barcode
      sanger_barcode*10+calculate_EAN13(barcode)
    end

    def sanger_barcode
      # Returns the machine barcode minus the EAN13 print checksum.
      raise ArgumentError, "Number : #{number} to big to generate a barcode." if number.to_s.size > 7
      prefix.machine_full + (number * 100) + calculate_checksum[0]
    end
  end

  class HumanBarcode
    include SharedBarcode

    attr_reader :human_barcode

    def initialize(human_barcode)
      @human_barcode = human_barcode
    end

    def calculate_machine_barcode
      if !valid?
        raise InvalidBarcode, "The human readable barcode was invalid, perhaps it was mistyped?"
      else
        super
      end
    end

    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    private
    def parse_barcode
      if /^(..)(.*)(.)$/ =~human_barcode
        @prefix ||= Prefix.from_human($1)
        @number ||= $2.to_i
        @checksum ||= Checksum.from_human($3)
      end
    end

    def valid?(prefix=nil)
      case
       when calculate_checksum != checksum.human
         then return false
       when !prefix.nil? && prefix.human != prefix
         then return false
       else
         true
       end
    end

  end

  class MachineBarcode
    include SharedBarcode

    attr_reader :machine_barcode

    def human_barcode
      @human_barcode ||= calculate_human_barcode
    end

    def initialize(machine_barcode)
      @machine_barcode = machine_barcode.to_i
    end

    def valid?
      check_EAN
    end
  end

  class SangerBarcode
    include SharedBarcode

    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    def human_barcode
      @machine_barcode ||= calculate_human_barcode
    end

    def initialize(prefix,number,suffix=nil)
      @prefix = prefix.is_a?(String) ? Prefix.from_human(prefix) : prefix
      @number = number.to_i
      @suffix = suffix
    end

    def valid?
      @number.to_s.size <= 7
    end

  end
end
