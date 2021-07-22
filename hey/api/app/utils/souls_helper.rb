module SoulsHelper
  def self.pubsub_queue(topic_name: "seino-schedule-scraper", message: "text!")
    pubsub = Google::Cloud::Pubsub.new(project: ENV["PROJECT_ID"])
    topic = pubsub.topic(topic_name)
    topic.publish(message)
  end

  def self.get_tables
    path = "./db/schema.rb"
    tables = []
    File.open(path, "r") do |f|
      f.each_line.with_index do |line, _i|
        tables << line.split("\"")[1] if line.include?("create_table")
      end
    end
    tables
  end
end
