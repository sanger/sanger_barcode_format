module SangerBarcodeable
  BarcodeError= Class.new(StandardError)
  InvalidBarcode = Class.new(BarcodeError)
  SuffixRequired = Class.new(BarcodeError)
  InvalidBarcodeOperation = Class.new(BarcodeError)
end
