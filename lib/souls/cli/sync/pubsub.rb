module Souls
  module Sync
    class << self
      def pubsub
        # coming soon
      end

      private

      def get_workers
        require("#{Souls.get_mother_path}/config/souls")
        worker_paths = Souls.configuration.workers.map { |n| n[:name] }
        response = {}
        Dir.chdir(Souls.get_mother_path.to_s) do
          worker_paths.each do |worker|
            mailers =
              Dir["apps/#{worker}/app/graphql/mutations/mailers/*.rb"].map do |file|
                file.gsub("apps/#{worker}/app/graphql/mutations/mailers/", "").gsub(".rb", "")
              end

            workers =
              Dir["apps/#{worker}/app/graphql/mutations/*.rb"].map do |file|
                file.gsub("apps/#{worker}/app/graphql/mutations/", "").gsub(".rb", "")
              end
            workers.delete("base_mutation")
            local_files = mailers + workers
          end
        end
      end
    end
  end
end
