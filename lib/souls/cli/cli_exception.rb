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

  class GcloudException < CLIException
    attr_reader :message

    def initialize
      message = "You either haven't created or don't have access to a GCP project." \
      "Please create a GCP project with the same name as this app."
      super(message)
      @message = message
    end
  end
end
