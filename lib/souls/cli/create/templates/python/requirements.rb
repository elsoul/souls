module Template
  module Node
    def self.requirements
      <<~PACKAGEJSON
        # Function dependencies, for example:
        # package>=version
      
      PACKAGEJSON
    end
  end
end
