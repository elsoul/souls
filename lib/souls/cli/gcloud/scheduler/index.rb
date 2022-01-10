module SOULs
  class CloudScheduler < Thor
    desc "awake [url]", "Set Ping Every 15min by Google Cloud Scheduler"
    def awake(url)
      app_name = SOULs.configuration.app
      system(
        "gcloud scheduler jobs create http #{app_name}-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri #{url} --http-method GET"
      )
    end

    desc "sync_schedules", "Collect schedules from queries and sync with GCloud"
    method_option :timezone, default: "Asia/Tokyo", aliases: "--timezone", desc: "Timezone e.g. Europe/Amsterdam"
    def sync_schedules
      require("./app")
      SOULs::Gcloud.new.config_set
      project_id = SOULs.configuration.project_id

      schedules_list = current_schedules
      worker_name = FileUtils.pwd.split("/").last
      Queries::BaseQuery.all_schedules.each do |k, v|
        job_name = "souls-#{worker_name}-#{k}".to_sym
        topic = "souls-#{worker_name}-#{k}"
        query_name = k.to_s.gsub("-", "").camelize(:lower)
        message_body = "query { #{query_name} { response }}"

        if schedules_list.include?(job_name)
          schedule = schedules_list[job_name]
          schedules_list.delete(job_name)
          next if schedule == v

          system(
            <<~COMMAND)
              gcloud scheduler jobs update pubsub #{job_name} --project=#{project_id} --quiet --schedule="#{v}" --topic="#{topic}" --message-body="#{message_body}" --time-zone="#{options[:timezone]}"
            COMMAND
        else
          system(
            <<~COMMAND)
              gcloud scheduler jobs create pubsub #{job_name} --project=#{project_id} --quiet --schedule="#{v}" --topic="#{topic}" --attributes="" --message-body="#{message_body}" --time-zone="#{options[:timezone]}"
            COMMAND
        end
      end

      schedules_list.each do |k, _|
        next unless k.match?(/^souls-#{worker_name}/)

        system("gcloud scheduler jobs delete #{k} -q >/dev/null 2>&1")
      end
    end

    private

    def current_schedules
      current_schedules = {}
      jobs = `gcloud scheduler jobs list`
      return {} if jobs.blank?

      jobs.split("\n")[1..].each do |line|
        columns = line.split(/\t| {2,}/)
        job_name = columns[0].to_sym
        crontab = columns[2].split(" (")[0]
        current_schedules[job_name] = crontab
      end

      current_schedules
    end
  end
end
