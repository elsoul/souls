require_relative "lib/souls/version"

Gem::Specification.new do |spec|
  spec.name          = "souls"
  spec.version       = Souls::VERSION
  spec.authors       = ["POPPIN-FUMI", "KishiTheMechanic", "James Neve"]
  spec.email         = ["f.kawasaki@elsoul.nl", "s.kishi@elsoul.nl", "jamesoneve@gmail.com"]

  spec.summary       = "SOULs is a Serverless Application Framework.
  SOULs has four strains, API, Worker, Console, Media, and can be used in combination according to the purpose.
  SOULs Backend GraphQL Ruby & Frontend Relay are Scalable and Easy to deploy to Google Cloud and Amazon Web Services"
  spec.description = "SOULs is a Serverless Application Framework.
  SOULs has four strains, API, Worker, Console, Media, and can be used in combination according to the purpose.
  SOULs Backend GraphQL Ruby & Frontend Relay are Scalable and Easy to deploy to Google Cloud and Amazon Web Services"
  spec.homepage      = "https://souls.elsoul.nl"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elsoul/souls"
  spec.metadata["changelog_uri"] = "https://github.com/elsoul/souls"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency("paint", "2.2.1")
  spec.add_runtime_dependency("whirly", "0.3.0")
end
