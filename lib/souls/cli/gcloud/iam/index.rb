module Souls
  module Gcloud
    module Iam
      class << self
        def create_service_account(service_account: "souls-app")
          system(
            "gcloud iam service-accounts create #{service_account} \
          --description='Souls Service Account' \
          --display-name=#{service_account}"
          )
        end

        def create_service_account_key(service_account: "souls-app", project_id: "souls-app")
          system(
            "gcloud iam service-accounts keys create ./config/keyfile.json \
            --iam-account #{service_account}@#{project_id}.iam.gserviceaccount.com"
          )
        end

        def export_key_to_console
          file_path = "config/keyfile.json"
          puts(Paint["======= below（ここから）=======", :cyan])
          text = []
          File.open(file_path, "r") do |line|
            line.each_line do |l|
              text << l
            end
          end
          key = text.join(",").gsub(/^,/, "").chomp!
          github_repo = `git remote show origin -n | grep 'Fetch URL:' | awk '{print $3}'`.strip
          puts(Paint[key, :white])
          puts(Paint["======= above（ここまで）=======", :cyan])
          github_secret_url = "#{github_repo}/settings/secrets/actions"
          souls_doc_url = "https://souls.elsoul.nl/docs/tutorial/zero-to-deploy/#43-github-シークレットキーの登録"
          txt1 = <<~TEXT

            ⬆⬆⬆　Copy the service account key above　⬆⬆⬆⬆

                            And

            Go to %{yellow_text}

            Reference: %{yellow_text2}
          TEXT
          puts(
            Paint % [
              txt1,
              :white,
              { yellow_text: [github_secret_url, :yellow], yellow_text2: [souls_doc_url, :yellow] }
            ]
          )
          FileUtils.rm(file_path)
        end

        def add_service_account_role(service_account: "souls-app", project_id: "souls-app", role: "roles/firebase.admin")
          system(
            "gcloud projects add-iam-policy-binding #{project_id} \
          --member='serviceAccount:#{service_account}@#{project_id}.iam.gserviceaccount.com' \
          --role=#{role}"
          )
        end

        def add_permissions(service_account: "souls-app", project_id: "souls-app")
          roles = [
            "roles/cloudsql.editor",
            "roles/containerregistry.ServiceAgent",
            "roles/pubsub.editor",
            "roles/datastore.user",
            "roles/iam.serviceAccountUser",
            "roles/run.admin",
            "roles/storage.admin"
          ]
          roles.each do |role|
            add_service_account_role(service_account: service_account, project_id: project_id, role: role)
          end
        end
      end
    end
  end
end
