module Template
  def self.functions_env_yaml
    <<~ENV
      FOO: bar
      BAZ: boo
    ENV
  end
end
