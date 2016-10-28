module SangerBarcodeable
  class Checksum
    def self.from_human(human_checksum)
      new(human_checksum: human_checksum)
    end

    def self.from_machine(machine_checksum)
      new(machine_checksum: machine_checksum)
    end

    def initialize(human_checksum: nil, machine_checksum: nil)
      raise BarcodeError, 'Must supply a human or machine checksum' unless human_checksum || machine_checksum
      @human = human_checksum
      @machine = machine_checksum.to_i if machine_checksum
    end

    def machine
      @machine ||= human.getbyte(0)
    end

    def human
      @human ||= @machine.chr
    end
  end
end
