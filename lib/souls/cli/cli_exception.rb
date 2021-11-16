module Souls
  class CLIException < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end
  end

  class PSQLException < CLIException
    attr_reader :message

    def initialize
      message = "It looks like there was a problem with the DB. Make sure PSQL is running with 'souls docker psql'"
      super(message)
      @message = message
    end
  end
end
