require_relative "lib/souls/version"

Gem::Specification.new do |gem|
  gem.name          = "souls"
  gem.version       = SOULs::VERSION
  gem.authors       = ["POPPIN-FUMI", "KishiTheMechanic", "James Neve"]
  gem.email         = ["f.kawasaki@elsoul.nl", "s.kishi@elsoul.nl", "jamesoneve@gmail.com"]

  gem.summary       = "Ruby Serverless Framework 'SOULs' | Ruby サーバーレスフレームワーク SOULs.
  Powered by Ruby GraphQL, Active Record, RSpec, RuboCop, and Google Cloud."
  gem.description = "Ruby Serverless Framework 'SOULs' | Ruby サーバーレスフレームワーク SOULs.
  Powered by Ruby GraphQL, Active Record, RSpec, RuboCop, and Google Cloud."
  gem.homepage      = "https://souls.elsoul.nl"
  gem.license       = "Apache-2.0"
  gem.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  gem.metadata["homepage_uri"] = gem.homepage
  gem.metadata["source_code_uri"] = "https://github.com/elsoul/souls"
  gem.metadata["changelog_uri"] = "https://github.com/elsoul/souls/releases/tag/v#{gem.version}"

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
  gem.add_runtime_dependency("activesupport", ">= 7.0.2.3")
  gem.add_runtime_dependency("foreman", ">= 0.87.2")
  gem.add_runtime_dependency("firebase_id_token", ">= 2.4.0")
  gem.add_runtime_dependency("google-cloud-pubsub", ">= 2.8.0")
  gem.add_runtime_dependency("graphql", "<= 1.13.10")
  gem.add_runtime_dependency("paint", ">= 2.2.1")
  gem.add_runtime_dependency("tty-prompt", ">= 0.23.1")
  gem.add_runtime_dependency("whirly", ">= 0.3.0")
  gem.add_runtime_dependency("httpclient", ">= 2.8.3")
  gem.add_runtime_dependency("retryable", ">= 3.0.5")
  gem.add_dependency("thor", ">= 1.2.1")
  gem.metadata = { "rubygems_mfa_required" => "true" }
end
