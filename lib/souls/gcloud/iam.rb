module Souls
  module Gcloud
    def self.create_service_account(service_account: "souls-app")
      `gcloud iam service-accounts create #{service_account} \
      --description="Souls Service Account" \
      --display-name="#{service_account}"`
    end

    def self.create_service_account_key(service_account: "souls-app")
      project_id = Souls.configuration.project_id
      `gcloud iam service-accounts keys create ./config/keyfile.json \
        --iam-account #{service_account}@#{project_id}.iam.gserviceaccount.com`
    end

    def self.add_service_account_role(service_account: "souls-app", role: "roles/firebase.admin")
      project_id = Souls.configuration.project_id
      `gcloud projects add-iam-policy-binding #{project_id} \
      --member="serviceAccount:#{service_account}@#{project_id}.iam.gserviceaccount.com" \
      --role="#{role}"`
    end

    def self.add_permissions(service_account: "souls-app")
      add_service_account_role(service_account: service_account, role: "roles/cloudsql.serviceAgent")
      add_service_account_role(service_account: service_account, role: "roles/containerregistry.ServiceAgent")
      add_service_account_role(service_account: service_account, role: "roles/pubsub.serviceAgent")
      add_service_account_role(service_account: service_account, role: "roles/firestore.serviceAgent")
      add_service_account_role(service_account: service_account, role: "roles/iam.serviceAccountUser")
    end
  end
end
