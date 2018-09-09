
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "brightcove_service/version"

Gem::Specification.new do |spec|
  spec.name          = "brightcove_service"
  spec.version       = BrightcoveService::VERSION
  spec.authors       = ["Anil Maurya"]
  spec.email         = ["anil@joshsoftware.com"]

  spec.summary       = %q{BrightcoveService Wrapper for Ruby}
  spec.description   = %q{BrightcoveService Wrapper for Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk-s3", "~> 1"
  spec.add_runtime_dependency "http", "~> 3.3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
