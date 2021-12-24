module Souls
  class Functions < Thor
    desc "deploy", "Deploy Cloud Functions"
    def deploy
      require(Souls.get_mother_path.to_s + "/config/souls")
      project_id = Souls.configuration.project_id
      Dir.chdir(Souls.get_functions_path.to_s) do
        system(
          "
          gcloud functions deploy souls_functions --project=#{project_id} \
          --runtime ruby27 --trigger-http --allow-unauthenticated --env-vars-file .env.yaml
          "
        )
      end
    end

    desc "dev", "Check SOULs Functions dev"
    def dev
      Dir.chdir(Souls.get_functions_path.to_s) do
        system("bundle exec functions-framework-ruby --target souls_functions")
      end
    end
  end
end
