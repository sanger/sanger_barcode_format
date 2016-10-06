module SangerBarcodeable
  class Prefix

    def self.from_human(human_prefix)
      new(human_prefix:human_prefix)
    end

    def self.from_machine(machine_prefix)
      new(machine_prefix:machine_prefix)
    end

    def initialize(human_prefix: nil,machine_prefix: nil)
      raise BarcodeError, 'Must supply a human or machine prefix' unless human_prefix||machine_prefix
      @human = human_prefix
      @machine = machine_prefix.to_i if machine_prefix
    end

    def machine
      @machine ||= calculate_machine
    end

    def machine_s
      machine_s = machine.to_s
      padding = above_zero(PREFIX_LENGTH-machine_s.length)
      machine_s.insert(0,'0'*padding)
    end

    def human
      @human ||= calculate_human
    end

    def machine_full
      machine * 10**(NUMBER_LENGTH + CHECKSUM_LENGTH)
    end

    private

    def calculate_machine
      first  = above_zero(human.getbyte(0)-ASCII_OFFSET)
      second = above_zero(human.getbyte(1)-ASCII_OFFSET)
      ((first * PREFIX_BASE) + second)
    end

    def calculate_human
      ((machine/PREFIX_BASE)+ASCII_OFFSET).chr + ((machine%PREFIX_BASE)+ASCII_OFFSET).chr
    end

    # Avoid needlessly creating an array
    def above_zero(value)
      value < 0 ? 0 : value
    end
  end
end
