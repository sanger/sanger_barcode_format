# This is a temporary storage space while I refactor
require 'sanger_barcodeable/shared_barcode'
module SangerBarcodeable

  # TO REMOVE
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

  # TO REMOVE
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

end
