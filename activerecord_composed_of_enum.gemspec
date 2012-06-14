# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_record/composed_of_enum/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Rob Hanlon']
  gem.email         = ['rob@mediapiston.com']
  gem.description   = 'Provides syntax for composing models of enums.'
  gem.summary       = 'Provides a composed_of_enum method for ActiveRecord '\
                      'models that binds enum classes with an enum integer '\
                      'column.'
  gem.homepage      = 'http://www.github.com/ohwillie/activerecord_composed_of_enum'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'activerecord_composed_of_enum'
  gem.require_paths = %w[lib]
  gem.version       = ActiveRecord::ComposedOfEnum::VERSION

  gem.add_development_dependency 'rspec', '2.10.0'
  gem.add_development_dependency 'activerecord', '3.2.6'
  gem.add_development_dependency 'sqlite3', '1.3.6'

  gem.add_dependency 'rbx-require-relative', '0.0.9'
end
