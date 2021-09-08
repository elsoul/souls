module Souls
  module Api::Generate
    def self.connection(class_name: "user")
      file_dir = "./app/graphql/types/connections/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      singularized_class_name = class_name.underscore.singularize
      file_path = "./app/graphql/types/connections/#{singularized_class_name}_connection.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          class Types::#{singularized_class_name.camelize}Connection < Types::BaseConnection
            edge_type(Types::#{singularized_class_name.camelize}Edge)
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
