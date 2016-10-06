module SangerBarcodeable
  class Prefix

    PREFIX_LENGTH = 3

    def self.from_human(human_prefix)
      new(human_prefix,nil)
    end

    def self.from_machine(machine_prefix)
      new(nil,machine_prefix)
    end

    def initialize(human_prefix,machine_prefix=nil)
      raise BarcodeError, 'Must supply a human or machine prefix' unless human_prefix||machine_prefix
      @human = human_prefix
      @machine = machine_prefix.to_i if machine_prefix
    end

    def machine
      @machine ||= calculate_machine
    end

    def machine_s
      machine_s = machine.to_s
      padding = [(PREFIX_LENGTH-machine_s.length),0].max
      machine_s.insert(0,'0'*padding)
    end

    def human
      @human ||= calculate_human
    end

    def machine_full
      machine * 1000000000
    end

    private

    def calculate_machine
      first_byte_value = human.getbyte(0)-64
      second_byte_value = human.getbyte(1)-64
      first  = first_byte_value < 0 ? 0 : first_byte_value
      second = second_byte_value < 0 ? 0 : second_byte_value
      ((first * 27) + second)
    end


    def calculate_human
      ((machine.to_i/27)+64).chr + ((machine.to_i%27)+64).chr
    end
  end
end
