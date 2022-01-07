module Template
  module Python
    def self.requirements(_args)
      <<~PACKAGEJSON
        # Function dependencies, for example:
        # package>=version

      PACKAGEJSON
    end
  end
end
