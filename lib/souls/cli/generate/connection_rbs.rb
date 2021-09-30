module Souls
  class Generate < Thor
    desc "connection_rbs [CLASS_NAME]", "Generate GraphQL Connection RBS from schema.rb"
    def connection_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types/connections/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}_connection.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Types
              class #{singularized_class_name.camelize}Connection < Types::BaseConnection
                def self.edge_type: (*untyped) -> untyped
              end
            end
          TEXT
        end
        puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      end
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
