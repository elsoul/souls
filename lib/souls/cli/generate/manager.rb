module Souls
  class Generate < Thor
    desc "manager [MANAGER_NAME]", "Generate GraphQL Mutation Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def manager(class_name)
      singularized_class_name = class_name.underscore.singularize
      unless FileUtils.pwd.split("/").last == "api"
        raise(StandardError, "You Are at Wrong Directory! Please Go to Api Directory!")
      end

      create_manager(class_name, options[:mutation])
      Souls::Generate.new.invoke(:manager_rbs, [singularized_class_name], { mutation: options[:mutation] })
      Souls::Generate.new.invoke(:rspec_manager, [singularized_class_name], { mutation: options[:mutation] })
    end

    private

    def create_manager(class_name, mutation)
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./app/graphql/mutations/managers/#{singularized_class_name}_manager"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{mutation}.rb"
      raise(StandardError, "Already Exist!") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            module Managers::#{singularized_class_name.camelize}Manager
              class #{mutation.underscore.camelize} < BaseMutation
                description "#{mutation} description"
                ## Edit `argument` and `field`
                argument :argument, String, required: false

                field :response, String, null: false

                def resolve(args)
                  # Define Here
                  { response: "success!" }
                end
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
