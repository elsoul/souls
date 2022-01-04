module Souls
  class Functions < Thor
    desc "deploy", "Deploy Cloud Functions"
    def deploy
      require(Souls.get_mother_path.to_s + "/config/souls")
      project_id = Souls.configuration.project_id
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

    desc "delete", "Delete SOULs Functions"
    def delete(name)
      require(Souls.get_mother_path.to_s + "/config/souls")
      project_id = Souls.configuration.project_id
      system("gcloud functions delete #{name} --project=#{project_id}")
      Dir.chdir(Souls.get_mother_path.to_s) do
        FileUtils.rm_rf("apps/#{name}")
      end
      Souls::Painter.success("Deleted #{name} functions!")
    end

    desc "url", "Get SOULs Functions URL"
    def url
      require(Souls.get_mother_path.to_s + "/config/souls")
      project_id = Souls.configuration.project_id
      current_dir = FileUtils.pwd.split("/").last
      Souls::Painter.success(`gcloud functions describe #{current_dir} --project=#{project_id}| grep url`)
    end

    desc "all_url", "Get SOULs Functions All URL"
    def all_url
      require(Souls.get_mother_path.to_s + "/config/souls")
      project_id = Souls.configuration.project_id
      Dir.chdir(Souls.get_mother_path.to_s) do
        souls_functions = Dir["apps/cf_*"]
        cf_dir = souls_functions.map { |n| n.split("/").last }
        cf_dir.each do |dir|
          Souls::Painter.success(`gcloud functions describe #{dir} --project=#{project_id}| grep url`)
        end
      end
    end

    desc "dev", "Check SOULs Functions dev"
    def dev
      Dir.chdir(Souls.get_functions_path.to_s) do
        current_dir = FileUtils.pwd.split("/").last
        system("bundle exec functions-framework-ruby --target #{current_dir}")
      end
    end
  end
end
