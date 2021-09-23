module Souls
  class Generate < Thor
    desc "manager [MANAGER_NAME]", "Generate GraphQL Mutation Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def manager(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./app/graphql/mutations/managers/#{singularized_class_name}_manager"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{options[:mutation]}.rb"
      raise(StandardError, "Already Exist!") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            module Managers::#{singularized_class_name.camelize}Manager
              class #{options[:mutation].underscore.camelize} < BaseMutation
                description "#{options[:mutation]} description"
                ## Edit `argument` and `field`
                argument :argment, String, required: true

                field :response, String, null: false

                def resolve(args)
                  # Define Here
                rescue StandardError => e
                  GraphQL::ExecutionError.new(e.to_s)
                end
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
