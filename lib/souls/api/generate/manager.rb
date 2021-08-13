module Souls
  module Api::Generate
    def self.manager(class_name: "souls")
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./app/graphql/mutations/managers/#{singularized_class_name}_manager"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{singularized_class_name}.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          class Types::#{singularized_class_name.camelize}Edge < module Mutations
            module Mailers
              class #{singularized_class_name.camelize}Mailer < BaseMutation
                description "Mail を送信します。"
                field :response, String, null: false

            node_type(Types::#{singularized_class_name.camelize}Type)
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue StandardError => e
      raise(StandardError, e)
    end
  end
end
