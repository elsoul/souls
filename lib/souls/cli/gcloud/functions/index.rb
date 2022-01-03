module Souls
  class Functions < Thor
    desc "deploy", "Deploy Cloud Functions"
    def deploy
      require(Souls.get_mother_path.to_s + "/config/souls")
      current_dir = FileUtils.pwd.split("/").last
      unless current_dir.match?(/^cf_/)
        Souls::Painter.error("You are at wrong dir!\nPlease go to `apps/functions` dir!")
        return false
      end

      runtime = current_dir.match(/cf_(\D+\d+)_/)[1]
      system(
        "
          gcloud functions deploy #{current_dir} --project=#{project_id} \
          --runtime #{runtime} --trigger-http --allow-unauthenticated --env-vars-file .env.yaml
          "
      )
    end

    desc "describe", "Describe SOULs Functions"
    def describe
      require(Souls.get_mother_path.to_s + "/config/souls")
      project_id = Souls.configuration.project_id
      system("gcloud functions describe souls_functions --project=#{project_id}")
    end

    desc "url", "Get SOULs Functions URL"
    def url
      require(Souls.get_mother_path.to_s + "/config/souls")
      project_id = Souls.configuration.project_id
      system("gcloud functions describe souls_functions --project=#{project_id}| grep url")
    end

    desc "dev", "Check SOULs Functions dev"
    def dev
      Dir.chdir(Souls.get_functions_path.to_s) do
        system("bundle exec functions-framework-ruby --target souls_functions")
      end
    end
  end
end
