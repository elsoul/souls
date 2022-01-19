module SOULs
  class CloudScheduler < Thor
    desc "awake [url]", "Set Ping by Google Cloud Scheduler: Cron e.g. '0 10 * * *' or 'every 10 hours'"
    def awake
      app_name = SOULs.configuration.app.gsub("_", "-")
      worker_names = SOULs.configuration.workers.map { |f| f[:name] }
      services = ["souls-#{app_name}-api"]
      worker_names.each { |worker| services << "souls-#{app_name}-#{worker}" }

      prompt = TTY::Prompt.new
      service = prompt.select("Select Service?", services)
      cron = prompt.ask("Cron Schedule?", default: "every 10 mins")

      url = SOULs::CloudRun.new.get_endpoint(service)
      system(
        "gcloud scheduler jobs create http #{app_name}-awake \
            --schedule '#{cron}' --uri #{url} --http-method GET"
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
        job_name = "souls-#{worker_name}-#{k.to_s.underscore.gsub('_', '-')}".to_sym
        topic = "souls-#{worker_name}-#{k.to_s.underscore.gsub('_', '-')}"
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
