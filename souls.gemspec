require_relative "lib/souls/version"

Gem::Specification.new do |gem|
  gem.name          = "souls"
  gem.version       = Souls::VERSION
  gem.authors       = ["POPPIN-FUMI", "KishiTheMechanic", "James Neve"]
  gem.email         = ["f.kawasaki@elsoul.nl", "s.kishi@elsoul.nl", "jamesoneve@gmail.com"]

  gem.summary       = "Build Serverless Apps faster like Rails.
  Powered by Ruby GraphQL, RBS/Steep, Active Record, RSpec, RuboCop, and Google Cloud. "
  gem.description = "Build Serverless Apps faster like Rails.
  Powered by Ruby GraphQL, RBS/Steep, Active Record, RSpec, RuboCop, and Google Cloud. "
  gem.homepage      = "https://souls.elsoul.nl"
  gem.license       = "Apache-2.0"
  gem.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  gem.metadata["homepage_uri"] = gem.homepage
  gem.metadata["source_code_uri"] = "https://github.com/elsoul/souls"
  gem.metadata["changelog_uri"] = "https://github.com/elsoul/souls"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      [
                        "exe/souls",
                        "README.md",
                        "CODE_OF_CONDUCT.md",
                        "LICENSE.txt"
                      ]
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency("activesupport", ">= 6.1.4")
  gem.add_runtime_dependency("foreman", ">= 0.87.2")
  gem.add_runtime_dependency("google-cloud-pubsub", ">= 2.8.0")
  gem.add_runtime_dependency("paint", ">= 2.2.1")
  gem.add_runtime_dependency("tty-prompt", ">= 0.23.1")
  gem.add_runtime_dependency("whirly", ">= 0.3.0")
  gem.add_dependency("thor", ">= 1.1.0")
end
