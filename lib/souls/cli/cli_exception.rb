module Souls
  class CLIException < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end
  end
end
