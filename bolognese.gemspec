require "date"
require File.expand_path("../lib/bolognese/version", __FILE__)

Gem::Specification.new do |s|
  s.authors       = "Martin Fenner"
  s.email         = "mfenner@datacite.org"
  s.name          = "bolognese"
  s.homepage      = "https://github.com/datacite/bolognese"
  s.summary       = "Ruby client library for conversion of DOI Metadata"
  s.date          = Date.today
  s.description   = "Ruby gem and command-line utility for conversion of DOI metadata from and to different metadata formats, including schema.org."
  s.require_paths = ["lib"]
  s.version       = Bolognese::VERSION
  s.extra_rdoc_files = ["README.md"]
  s.license       = 'MIT'
  s.required_ruby_version = ['>= 3.2', '< 4.1']

  # Declare dependencies here, rather than in the Gemfile
  s.add_dependency 'maremma', '~> 6.0'
  s.add_dependency 'nokogiri', '~> 1.19', '>= 1.19.1'
  s.add_dependency 'loofah', '~> 2.25'
  s.add_dependency 'builder', '~> 3.3'
  s.add_dependency 'activesupport', "~> 8.1", ">= 8.1.2"
  s.add_dependency 'bibtex-ruby', '~> 6.2'
  s.add_dependency 'thor', '~> 1.5'
  s.add_dependency 'namae', '~> 1.2'
  s.add_dependency 'edtf', '~> 3.2'
  s.add_dependency 'citeproc-ruby', '~> 2.1', '>= 2.1.8'
  s.add_dependency 'csl-styles', '~> 2.0', '>= 2.0.2'
  s.add_dependency 'iso8601', '~> 0.13.0'
  s.add_dependency 'json-ld-preloaded', '~> 3.3', '>= 3.3.2'
  s.add_dependency 'jsonlint', '~> 0.4.0'
  s.add_dependency 'oj', '~> 3.16', '>= 3.16.15'
  s.add_dependency 'rdf-turtle', '~> 3.3', '>= 3.3.1'
  s.add_dependency 'rdf-rdfxml', '~> 3.3'
  s.add_dependency 'gender_detector', '~> 2.1'
  s.add_dependency 'concurrent-ruby', '~> 1.3', '>= 1.3.6'
  s.add_dependency 'csv', '~> 3.3', '>= 3.3.5'
  s.add_development_dependency 'bundler', '>= 2.0'
  s.add_development_dependency 'irb'
  s.add_development_dependency 'rspec', '~> 3.13', '>= 3.13.2'
  s.add_development_dependency 'rake', '~> 13.3', '>= 13.3.1'
  s.add_development_dependency 'rack-test', '~> 2.2'
  s.add_development_dependency 'vcr', '~> 6.4'
  s.add_development_dependency 'webmock', '~> 3.26', '>= 3.26.1'
  s.add_development_dependency 'simplecov', '0.22.0'
  s.add_development_dependency 'byebug'

  s.require_paths = ["lib"]
  s.files = `git ls-files`.split($/).reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.executables = ["bolognese"]
end
