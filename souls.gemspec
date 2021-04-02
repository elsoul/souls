require_relative "lib/souls/version"

Gem::Specification.new do |spec|
  spec.name          = "souls"
  spec.version       = Souls::VERSION
  spec.authors       = ["POPPIN-FUMI", "KishiTheMechanic", "James Neve"]
  spec.email         = ["fumitake.kawasaki@el-soul.com", "shota.kishi@el-soul.com", "jamesoneve@gmail.com"]

  spec.summary       = "SOULS is a GraphQL Based Web Application Framework for Microservices on Multi Cloud Platform such as Google Cloud Platform, Amazon Web Services, and Alibaba Cloud. Auto deploy with scalable condition. You can focus on business logic. No more infra problems."
  spec.description   = "SOULS is a Web Application Framework for Microservices on Multi Cloud Platform such as Google Cloud Platform, Amazon Web Services, and Alibaba Cloud. Auto deploy with scalable condition. You can focus on business logic. No more infra problems."
  spec.homepage      = "https://github.com/elsoul/souls"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elsoul/souls"
  spec.metadata["changelog_uri"] = "https://github.com/elsoul/souls"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
