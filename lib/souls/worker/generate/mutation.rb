module Souls
  module Worker
    module Generate
      class << self
        def mutation(class_name: "csv_export")
          file_dir = "./app/graphql/mutations/"
          FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
          file_path = "#{file_dir}#{class_name.singularize}_job.rb"
          raise(StandardError, "Mailer already exist! #{file_path}") if File.exist?(file_path)

          File.open(file_path, "w") do |f|
            f.write(<<~TEXT)
              module Mutations
                class #{class_name.camelize}Job < BaseMutation
                  description "Job Description"
                  field :response, String, null: false

                  def resolve
                    # Define Job Here

                    { response: "Job queued!" }
                  rescue StandardError => e
                    GraphQL::ExecutionError.new(e.to_s)
                  end
              end
            TEXT
          end
          puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
          file_path
        end
      end
    end
  end
end
