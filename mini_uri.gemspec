# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "mini_uri"
  spec.version       = "0.9.1"
  spec.authors       = ["Alex Pilon"]
  spec.email         = ["apilo088@gmail.com"]

  spec.summary       = "Generate short, uncrawlable URI"
  spec.description   = "Generate short, uncrawlable URI"
  spec.homepage      = "https://github.com/MadMub/mini-uri"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "base62", "~> 1.0"
end
