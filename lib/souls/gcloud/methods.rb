module Souls
  module Gcloud
    class << self
      def return_method(args)
        method = args[1]
        case method
        when "get_iam_key"
          app_name = Souls.configuration.app
          project_id = Souls.configuration.project_id
          Souls::Gcloud.create_service_account(service_account: app_name)
          Souls::Gcloud.create_service_account_key(service_account: app_name, project_id: project_id)
          Souls::Gcloud.export_key_to_console
          Souls::Gcloud.enable_permissions
        when "auth_login"
          project_id = Souls.configuration.project_id
          Souls::Gcloud.auth_login(project_id: project_id)
        when "enable_permissions"
          Souls::Gcloud.enable_permissions
        when "create_pubsub_topic"
          topic_name = args[2] || "send-user-mail"
          Souls::Gcloud.create_pubsub_topic(topic_name: topic_name)
        when "create_pubsub_subscription"
          project_id = Souls.configuration.project_id
          topic_name = args[2] || "send-user-mail"
          service_account = "#{Souls.configuration.app}@#{project_id}.iam.gserviceaccount.com"
          endpoint = Souls.configuration.worker_endpoint
          Souls::Gcloud.create_pubsub_subscription(
            topic_name: topic_name,
            project_id: project_id,
            service_account: service_account,
            endpoint: endpoint
          )
        when "create_sql_instance"
          instance_name = "#{Souls.configuration.app}-db"
          root_pass = args[2] || "password"
          zone = args[3] || "asia-northeast1-b"
          Souls::Gcloud.create_sql_instance(instance_name: instance_name, root_pass: root_pass, zone: zone)
        when "create_service_account"
          service_account = Souls.configuration.app
          Souls::Gcloud.create_service_account(service_account: service_account)
        when "create_service_account_key"
          service_account = Souls.configuration.app
          project_id = Souls.configuration.project_id
          Souls::Gcloud.create_service_account_key(service_account: service_account, project_id: project_id)
        when "add_service_account_role"
          service_account = Souls.configuration.app
          project_id = Souls.configuration.project_id
          role = args[2] || "roles/firebase.admin"
          Souls::Gcloud.add_service_account_role(service_account: service_account, project_id: project_id, role: role)
        when "add_permissions"
          service_account = Souls.configuration.app
          Souls::Gcloud.add_permissions(service_account: service_account)
        else
          raise(StandardError, "Wrong Method!")
        end
      end
    end
  end
end
