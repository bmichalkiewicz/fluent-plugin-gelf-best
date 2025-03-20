Gem::Specification.new do |spec|
  spec.name           = "fluent-plugin-gelf-best"
  spec.version        = File.read('VERSION')
  spec.authors        = ["Alex Yamauchi", "Eric Searcy", "Bartosz Michalkiewicz"]
  spec.licenses       = ["Apache-2.0"]
  spec.email          = ["bartosz.michalkiewicz@outlook.com"]

  spec.summary     = "Sends Fluentd events Graylog2 by GELF"
  spec.homepage    = "https://github.com/bmichalkiewicz/fluent-plugin-gelf-best"

  spec.files         = Dir["{lib}/**/*", "LICENSE", "README.md"]
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", ">= 1.8.0"
  spec.add_runtime_dependency "gelf_redux", ">= 4.1.0"
  spec.add_runtime_dependency "oj"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "rake"
end
