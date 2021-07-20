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

    def graphql_query(mutation: "SendUserMailJob", args: {})
      if args.blank?
        %(mutation { #{mutation}(input: {}) {
            response
          }
        })
      else
        inputs = ""
        args.each do |key, value|
          inputs +=
            if value.instance_of?(String)
              "#{key.to_s.underscore.camelize(:lower)}: \"#{value}\" "
            else
              "#{key.to_s.underscore.camelize(:lower)}: #{value} "
            end
        end
        %(mutation { #{mutation.to_s.underscore.camelize(:lower)}(input: {#{inputs}}) {
            response
          }
        })
      end
    end

    def check_user_permissions(user, obj, method)
      raise(StandardError, "Invalid or Missing Token") unless user

      policy_class = obj.class.name + "Policy"
      policy_clazz = policy_class.constantize.new(user, obj)
      permission = policy_clazz.public_send(method)
      raise(Pundit::NotAuthorizedError, "permission error!") unless permission
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
