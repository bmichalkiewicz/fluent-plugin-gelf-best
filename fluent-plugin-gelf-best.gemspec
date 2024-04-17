# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent-plugin-gelf-best/version'

Gem::Specification.new do |spec|
  spec.name        = "fluent-plugin-gelf-best"
  spec.version     = FluentPluginGelfBest::VERSION
  spec.authors     = ["Alex Yamauchi", "Eric Searcy", "Bartosz Michaliewicz"]
  spec.licenses       = ["Apache-2.0"]
  spec.email          = ["bartosz.michalkiewicz@outlook.com"]

  spec.summary     = "Sends Fluentd events Graylog2 by GELF"
  spec.homepage    = "https://github.com/bmichalkiewicz/fluent-plugin-gelf-best"

  spec.files      = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", ">=1.0.0"
  spec.add_runtime_dependency "gelf", ">= 2.0.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "rake"
end
