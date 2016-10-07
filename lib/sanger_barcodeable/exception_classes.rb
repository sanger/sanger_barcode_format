module SangerBarcodeable
  BarcodeError= Class.new(StandardError)
  InvalidBarcode = Class.new(BarcodeError)
  ChecksumRequired = Class.new(BarcodeError)
  InvalidBarcodeOperation = Class.new(BarcodeError)
end
