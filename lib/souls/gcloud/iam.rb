module Souls
  module Gcloud
    class << self
      def create_service_account service_account: "souls-app"
        `gcloud iam service-accounts create #{service_account} \
        --description="Souls Service Account" \
        --display-name="#{service_account}"`
      end

      def create_service_account_key service_account: "souls-app"
        project_id = Souls.configuration.project_id
        `gcloud iam service-accounts keys create ./config/keyfile.json \
          --iam-account #{service_account}@#{project_id}.iam.gserviceaccount.com`
      end

      def add_service_account_role service_account: "souls-app", role: "roles/firebase.admin"
        project_id = Souls.configuration.project_id
        `gcloud projects add-iam-policy-binding #{project_id} \
        --member="serviceAccount:#{service_account}@#{project_id}.iam.gserviceaccount.com" \
        --role="#{role}"`
      end

      def add_permissions service_account: "souls-app"
        self.add_service_account_role service_account: service_account, role: "roles/cloudsql.serviceAgent"
        self.add_service_account_role service_account: service_account, role: "roles/containerregistry.ServiceAgent"
        self.add_service_account_role service_account: service_account, role: "roles/pubsub.serviceAgent"
        self.add_service_account_role service_account: service_account, role: "roles/firestore.serviceAgent"
        self.add_service_account_role service_account: service_account, role: "roles/iam.serviceAccountUser"
      end
    end
  end
end
