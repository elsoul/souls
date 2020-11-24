require_relative 'lib/souls/version'

Gem::Specification.new do |spec|
  spec.name          = "souls"
  spec.version       = Souls::VERSION
  spec.authors       = ["POPPIN-FUMI", "KishiTheMechanic"]
  spec.email         = ["fumitake.kawasaki@el-soul.com", "shota.kishi@el-soul.com"]

  spec.summary       = "SOULS is a Web Application Framework for Microservices on Google Cloud Platform."
  spec.description   = "SOULS is a Web Application Framework for Microservices on Google Cloud Platform."
  spec.homepage      = "https://github.com/elsoul/souls"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elsoul/souls"
  spec.metadata["changelog_uri"] = "https://github.com/elsoul/souls"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency("google-cloud-firestore", "2.4.0")
  spec.add_dependency("mechanize", "2.7.6")
end
