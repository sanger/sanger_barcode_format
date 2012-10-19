# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sanger_barcodeable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["James Glover"]
  gem.email         = ["jg16@sanger.ac.uk"]
  gem.description   = %q{Holds the sanger barcode model}
  gem.summary       = %q{Sanger Barcodeable}
  gem.homepage      = "http://www.sanger.ac.uk"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sanger_barcodeable"
  gem.require_paths = ["lib"]
  gem.version       = SangerBarcodeable::VERSION

  gem.add_development_dependency('rake','~>0.9.2.2')
  gem.add_development_dependency('rspec','~>2.11.0')
end
