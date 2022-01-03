module Template
  module Go
    def self.go(_args)
      <<~APP
        module example.com/cloudfunction
      APP
    end
  end
end
