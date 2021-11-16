module Souls
  class CLIException < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = "abc123"
    end
  end
end
