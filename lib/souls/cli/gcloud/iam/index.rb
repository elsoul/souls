module SOULs
  class Iam < Thor
    desc "setup_key", "Create Google Cloud IAM Service Account Key And Set All Permissions"
    def setup_key
      Whirly.start(spinner: "clock", interval: 420, stop: "🎉") do
        Whirly.status = "Setting up credentials and permissions..."
        region = SOULs.configuration.region
        SOULs::Gcloud.new.auth_login
        SOULs::Upgrade.new.config
        create_service_account
        create_service_account_key
        SOULs::Gcloud.new.enable_permissions
        add_permissions
        begin
          system("gcloud app create --region=#{region} --quiet")
        rescue StandardError, error
          puts("gcloud app region is Already exist! - SOULs::Gcloud::Iam.setup_key")
        end
        begin
          set_gh_secret_json
        rescue StandardError
          export_key_to_console
        end
      end
      SOULs::Painter.success("You're all set!")
      true
    end

    private

    desc "create_service_account", "Create Google Cloud IAM Service Account"
    def create_service_account
      app_name = SOULs.configuration.app
      system(
        "gcloud iam service-accounts create #{app_name} \
          --description='SOULs Service Account' \
          --display-name=#{app_name}"
      )
    end

    desc "create_service_account_key", "Create Google Cloud Service Account Key"
    def create_service_account_key
      app_name = SOULs.configuration.app
      project_id = SOULs.configuration.project_id
      system(
        "gcloud iam service-accounts keys create ./config/keyfile.json \
            --iam-account #{app_name}@#{project_id}.iam.gserviceaccount.com"
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
      github_repo = "https://github.com/#{github_repo.match(/:(.+).git/)[1]}" if github_repo.include?("git@github")
      puts(Paint[key, :white])
      puts(Paint["======= above（ここまで）=======", :cyan])
      github_secret_url = "#{github_repo}/settings/secrets/actions"
      souls_doc_url = "https://souls.elsoul.nl/docs/tutorial/zero-to-deploy/#github-シークレットキーの登録"
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
      FileUtils.rm_f(file_path)
    end

    def add_service_account_role(role: "roles/firebase.admin")
      app_name = SOULs.configuration.app
      project_id = SOULs.configuration.project_id
      system(
        "gcloud projects add-iam-policy-binding #{project_id} \
          --member='serviceAccount:#{app_name}@#{project_id}.iam.gserviceaccount.com' \
          --role=#{role}"
      )
    end

    def add_permissions
      roles = [
        "roles/cloudsql.editor",
        "roles/containerregistry.ServiceAgent",
        "roles/pubsub.editor",
        "roles/datastore.user",
        "roles/iam.serviceAccountUser",
        "roles/run.admin",
        "roles/storage.admin",
        "roles/storage.objectAdmin",
        "roles/cloudscheduler.admin",
        "roles/appengine.appCreator",
        "roles/logging.admin",
        "roles/cloudtranslate.admin"
      ]
      roles.each do |role|
        add_service_account_role(role: role)
      end
    end

    def set_gh_secret_json
      file_path = "config/keyfile.json"
      system("gh secret set SOULS_GCP_SA_KEY < #{file_path}")
      FileUtils.rm(file_path)
    end
  end
end
