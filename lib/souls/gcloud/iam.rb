module Souls
  module Gcloud
    class << self
      def create_service_account(args)
        service_account = args[:service_account] || "souls-app"
        system(
          "gcloud iam service-accounts create #{service_account} \
        --description='Souls Service Account' \
        --display-name=#{service_account}"
        )
      end

      def create_service_account_key(args)
        service_account = args[:service_account] || "souls-app"
        project_id = args[:project_id] || "souls-app"
        system(
          "gcloud iam service-accounts keys create ./config/keyfile.json \
          --iam-account #{service_account}@#{project_id}.iam.gserviceaccount.com"
        )
      end

      def add_service_account_role(args)
        service_account = args[:service_account] || "souls-app"
        project_id = args[:project_id] || "souls-app"
        role = args[:role] || "roles/firebase.admin"
        `gcloud projects add-iam-policy-binding #{project_id} \
        --member="serviceAccount:#{service_account}@#{project_id}.iam.gserviceaccount.com" \
        --role="#{role}"`
      end

      def add_permissions(args)
        service_account = args[:service_account] || "souls-app"
        roles = [
          "roles/cloudsql.serviceAgent",
          "roles/containerregistry.ServiceAgent",
          "roles/pubsub.serviceAgent",
          "roles/firestore.serviceAgent",
          "roles/iam.serviceAccountUser"
        ]
        roles.each do |role|
          add_service_account_role(service_account: service_account, role: role)
        end
      end
    end
  end
end
