module SOULs
  class Functions < Thor
    desc "deploy", "Deploy Cloud Functions"
    def deploy
      require(SOULs.get_mother_path.to_s + "/config/souls")
      project_id = SOULs.configuration.project_id
      current_dir = FileUtils.pwd.split("/").last
      unless current_dir.match?(/^cf-/)
        SOULs::Painter.error("You are at wrong dir!\nPlease go to `apps/functions` dir!")
        return false
      end

      runtime = current_dir.match(/cf-(\D+\d+)-/)[1]
      runtime_lang = current_dir.match(/^cf-(\D+)\d+-/)
      entry_point =
        case runtime_lang
        when "nodejs"
          current_dir.underscore.camelize(:lower)
        when "python"
          current_dir.underscore
        when "go"
          current_dir.underscore.camelize
        else
          current_dir
        end
      system(
        "
          gcloud functions deploy #{current_dir} --entry-point=#{entry_point} --project=#{project_id} \
          --runtime #{runtime} --trigger-http --allow-unauthenticated --env-vars-file .env.yaml
          "
      )
    end

    desc "describe", "Describe SOULs Functions"
    def describe
      require(SOULs.get_mother_path.to_s + "/config/souls")
      current_dir = FileUtils.pwd.split("/").last
      project_id = SOULs.configuration.project_id
      system("gcloud functions describe #{current_dir} --project=#{project_id}")
    end

    desc "delete [name]", "Delete SOULs Functions"
    def delete(name)
      require(SOULs.get_mother_path.to_s + "/config/souls")
      project_id = SOULs.configuration.project_id
      system("gcloud functions delete #{name} --project=#{project_id}")
      Dir.chdir(SOULs.get_mother_path.to_s) do
        FileUtils.rm_rf("apps/#{name}")
      end
      SOULs::Painter.success("Deleted #{name} functions!")
    end

    desc "url", "Get SOULs Functions URL"
    def url
      require(SOULs.get_mother_path.to_s + "/config/souls")
      project_id = SOULs.configuration.project_id
      current_dir = FileUtils.pwd.split("/").last
      SOULs::Painter.success(`gcloud functions describe #{current_dir} --project=#{project_id}| grep url`)
    end

    desc "all_url", "Get SOULs Functions All URL"
    def all_url
      require(SOULs.get_mother_path.to_s + "/config/souls")
      project_id = SOULs.configuration.project_id
      Dir.chdir(SOULs.get_mother_path.to_s) do
        souls_functions = Dir["apps/cf-*"]
        cf_dir = souls_functions.map { |n| n.split("/").last }
        cf_dir.each do |dir|
          SOULs::Painter.success(`gcloud functions describe #{dir} --project=#{project_id}| grep url`)
        end
      end
    end

    desc "dev", "Check SOULs Functions dev"
    def dev
      Dir.chdir(SOULs.get_functions_path.to_s) do
        current_dir = FileUtils.pwd.split("/").last
        system("bundle exec functions-framework-ruby --target #{current_dir}")
      end
    end
  end
end
