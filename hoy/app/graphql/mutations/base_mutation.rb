module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def fb_auth(token:)
      FirebaseIdToken::Certificates.request!
      sleep(3) if ENV["RACK_ENV"] == "development"
      @payload = FirebaseIdToken::Signature.verify(token)
      raise(ArgumentError, "Invalid or Missing Token") if @payload.blank?

      @payload
    end

    def auth_check(context)
      raise(GraphQL::ExecutionError, "You need to sign in!!") if context[:user].nil?
    end

    def get_token(token)
      JsonWebToken.decode(token)
    end

    def production?
      ENV["RACK_ENV"] == "production"
    end

    def get_instance_id
      `curl http://metadata.google.internal/computeMetadata/v1/instance/id -H Metadata-Flavor:Google`
    end
  end
end
