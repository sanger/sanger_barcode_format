# frozen_string_literal: true

require File.expand_path('lib/sanger_barcode_format/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ['James Glover']
  gem.email         = ['jg16@sanger.ac.uk']
  gem.description   = 'Holds the sanger barcode model'
  gem.summary       = 'Sanger Barcode Format'
  gem.homepage      = 'http://www.sanger.ac.uk'

  gem.files         = `git ls-files`.split
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = 'sanger_barcode_format'
  gem.require_paths = ['lib']
  gem.version       = SBCF::VERSION

  gem.required_ruby_version = '>= 2.5.0'
end
