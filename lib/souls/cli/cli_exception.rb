module Souls
  class CLIException < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end

    def psql_exception
      initialize("It looks like there was a problem with the DB. Make sure PSQL is running with 'souls docker psql'")
    end
  end
end
