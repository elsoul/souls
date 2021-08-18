require_relative "lib/souls/version"

Gem::Specification.new do |gem|
  gem.name          = "souls"
  gem.version       = Souls::VERSION
  gem.authors       = ["POPPIN-FUMI", "KishiTheMechanic", "James Neve"]
  gem.email         = ["f.kawasaki@elsoul.nl", "s.kishi@elsoul.nl", "jamesoneve@gmail.com"]

  gem.summary       = "SOULs はサーバーレスフルスタックフレームワークです。柔軟な Ruby GraphQL API と Worker はルーティングの必要がありません。
  クラウド環境への自動デプロイ、CI/CD ワークフローを標準装備。開発者がビジネスロジックに集中し、楽しくコードが書けるような環境を目指しています。"
  gem.description = "SOULs はサーバーレスフルスタックフレームワークです。柔軟な Ruby GraphQL API と Worker はルーティングの必要がありません。
  クラウド環境への自動デプロイ、CI/CD ワークフローを標準装備。開発者がビジネスロジックに集中し、楽しくコードが書けるような環境を目指しています。"
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
  gem.add_runtime_dependency("activesupport", "6.1.4")
  gem.add_runtime_dependency("foreman", "0.87.2")
  gem.add_runtime_dependency("paint", "2.2.1")
  gem.add_runtime_dependency("tty-prompt", "0.23.1")
  gem.add_runtime_dependency("whirly", "0.3.0")
end
