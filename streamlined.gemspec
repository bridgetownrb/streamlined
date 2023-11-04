# frozen_string_literal: true

require_relative "lib/streamlined/version"

Gem::Specification.new do |spec|
  spec.name = "streamlined"
  spec.version = Streamlined::VERSION
  spec.author = "Bridgetown Team"
  spec.email = "maintainers@bridgetownrb.com"

  spec.summary = "Component rendering for Ruby using streamlined procs & heredocs."
  spec.homepage = "https://github.com/bridgetownrb/streamlined"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "serbea", ">= 2.1"
  spec.add_dependency "zeitwerk", "~> 2.5"
end
