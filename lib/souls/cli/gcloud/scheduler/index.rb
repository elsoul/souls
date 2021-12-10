module Souls
  class CloudScheduler < Thor
    desc "awake", "Set Ping Every 15min by Google Cloud Scheduler"
    method_option :url, default: "https://souls.souls.nl", aliases: "--url", desc: "Set URL"
    def awake
      app_name = Souls.configuration.app
      system(
        "gcloud scheduler jobs create http #{app_name}-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri #{options[:url]} --http-method GET"
      )
    end

    desc "sync_schedules", "Collect schedules from queries and sync with GCloud"
    method_option :timezone, default: "Asia/Tokyo", aliases: "--timezone", desc: "Timezone e.g. Europe/Amsterdam"
    def sync_schedules
      require("./app")
      Souls::Gcloud.new.config_set
      project_id = Souls.configuration.project_id

      schedules_list = current_schedules

      Queries::BaseQuery.all_schedules.each do |k, v|
        worker_name = FileUtils.pwd.split("/").last
        job_name = "souls_#{worker_name}_#{k.to_s.underscore}".to_sym
        topic = "souls_#{worker_name}_#{k.to_s.underscore}"
        message_body = "query { #{k.to_s.camelize(:lower)} { response }}"

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
        next unless k.match?(/^souls_/)

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
