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
    def sync_schedules
      require("./app")
      Souls::Gcloud.new.config_set
      project_id = Souls.configuration.project_id

      schedules_list = current_schedules

      Queries::BaseQuery.all_schedules.each do |k, v|
        worker_name = FileUtils.pwd.split("/").last
        job_name = "#{worker_name}_#{k.to_s.underscore}".to_sym

        if schedules_list.include?(job_name)
          schedule = schedules_list[job_name]
          schedules_list.delete(job_name)
          puts("Schedule V")
          puts(schedule)
          puts(v)
          next if schedule == v

          system(
            <<~COMMAND)
              gcloud scheduler jobs update pubsub #{job_name} --project=#{project_id} --quiet --schedule="#{v}" --topic="#{k}" --attributes="" --message-body="#{k}"
            COMMAND
        else
          system(
            <<~COMMAND)
              gcloud scheduler jobs create pubsub #{job_name} --project=#{project_id} --quiet --schedule="#{v}" --topic="#{k}" --attributes="" --message-body="#{k}"
            COMMAND
        end
      end

      puts(schedules_list)

      schedules_list.each do |k, _|
        system("gcloud scheduler jobs delete #{k} -q >/dev/null 2>&1")
      end
    end

    private

    def current_schedules
      current_schedules = {}
      `gcloud scheduler jobs list`.split("\n")[1..].each do |line|
        columns = line.split(/\t| {2,}/)
        job_name = columns[0].to_sym
        crontab = columns[2].split(" (")[0]
        current_schedules[job_name] = crontab
      end

      current_schedules
    end
  end
end
