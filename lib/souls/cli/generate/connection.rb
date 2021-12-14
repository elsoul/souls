module Souls
  class Generate < Thor
    desc "connection [CLASS_NAME]", "Generate GraphQL Connection from schema.rb"
    def connection(class_name)
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
      Souls::Painter.create_file(file_path.to_s)
      file_path
    end
  end
end
