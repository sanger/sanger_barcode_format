#require "sanger_barcodeable/version"

module Barcode

  BarcodeError= Class.new(StandardError)
  InvalidBarcode = Class.new(BarcodeError)
  InvalidBarcodeOperation = Class.new(BarcodeError)

  def self.from_human(human_barcode)
    Barcode::HumanBarcode.new(human_barcode)
  end

  def self.from_machine(machine_barcode)
    Barcode::MachineBarcode.new(machine_barcode)
  end

  def self.from_prefix_and_number(human_prefix,short_barcode)
    Barcode::BuiltBarcode.new(human_prefix,short_barcode)
  end

  class Prefix

    def self.from_human(human_prefix)
      new(human_prefix,nil)
    end

    def self.from_machine(machine_prefix)
      new(nil,machine_prefix)
    end

    def initialize(human_prefix,machine_prefix=nil)
      raise BarcodeError, 'Must supply a human or machine prefix' unless human_prefix||machine_prefix
      @human = human_prefix
      @machine = machine_prefix
    end

    def machine
      @machine ||= calculate_machine
    end

    def human
      @human ||= calculate_human
    end

    def machine_full
      machine * 1000000000
    end

    private

    def calculate_machine
      first  = human[0]-64
      second = human[1]-64
      first  = 0 if first < 0
      second  = 0 if second < 0
      ((first * 27) + second)
    end

    def calculate_human
      ((machine.to_i/27)+64).chr + ((machine.to_i%27)+64).chr
    end

  end

  class HumanChecksum

    attr_reader :human

    def initialize(human_checksum)
      @human = human_checksum
    end

    def machine
      @machine ||= human[0]
    end
  end

  class MachineChecksum

    attr_reader :machine

    def initialize(machine_checksum)
      @machine= machine_checksum.to_i
    end

    def human
      @human ||= @machine.chr
    end

  end

  #### Barcode Methods ###########################################################

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
      [prefix.machine,number,checksum.machine]
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
        @checksum ||= MachineChecksum.new($3.to_i)
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
    include Barcode::SharedBarcode

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
        @checksum ||= HumanChecksum.new($3)
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
    include Barcode::SharedBarcode

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

  class BuiltBarcode
    include Barcode::SharedBarcode

    def machine_barcode
      @machine_barcode ||= calculate_machine_barcode
    end

    def human_barcode
      @machine_barcode ||= calculate_human_barcode
    end

    def initialize(human_prefix,number)
      @prefix = Prefix.from_human(human_prefix)
      @number = number.to_i
    end

    def valid?
      @number.to_s.size <= 7
    end

  end

  # Compatability Methods #############################

  def self.split_barcode(code)
    MachineBarcode.new(code).split_barcode
  end

  def self.split_human_barcode(code)
    HumanBarcode.new(code).split_human_barcode
  end

  def self.number_to_human(machine_barcode)
    begin
      MachineBarcode.new(machine_barcode).number.to_s
    rescue InvalidBarcode
      # Catching exceptions to preseve old behaviour
      nil
    end
  end

  def self.prefix_from_barcode(machine_barcode)
    begin
      MachineBarcode.new(machine_barcode).prefix.human
    rescue InvalidBarcode
      # Catching exceptions to preseve old behaviour
      nil
    end
  end

  def self.prefix_to_human(prefix)
    Prefix.from_machine(prefix).human
  end

  def self.human_to_machine_barcode(human_barcode)
    HumanBarcode.new(human_barcode).machine_barcode
  end

  def self.barcode_to_human(code)
    begin
      MachineBarcode.new(code).human_barcode
    rescue InvalidBarcode
      # Catching exceptions to preseve old behaviour
      nil
    end
  end

  def self.check_EAN(code)
    MachineBarcode.new(code).check_EAN
  end

  # Returns the Human barcode or raises an InvalidBarcode exception if there is a problem.  The barcode is
  # considered invalid if it does not translate to a Human barcode or, when the optional +prefix+ is specified,
  # its human equivalent does not match.
  def self.barcode_to_human!(code, prefix = nil)
    barcode = MachineBarcode.new(code) or raise InvalidBarcode, "Barcode #{ code } appears to be invalid"
    unless prefix.nil? or barcode.prefix.human == prefix
      raise InvalidBarcode, "Barcode #{ code } (#{ barcode.human_barcode }) does not match prefix #{ prefix }"
    end
    barcode.human_barcode
  end

  def self.calculate_barcode(human_prefix, number)
    BuiltBarcode.new(human_prefix,number).machine_barcode
  end

  def self.calculate_checksum(human_prefix, number)
    BuiltBarcode.new(human_prefix,number).checksum.human
  end

end
