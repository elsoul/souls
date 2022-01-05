module SOULs
  class Generate < Thor
    desc "edge [CLASS_NAME]", "Generate GraphQL Edge from schema.rb"
    def edge(class_name)
      file_dir = "./app/graphql/types/edges"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      singularized_class_name = class_name.underscore.singularize
      file_path = "./app/graphql/types/edges/#{singularized_class_name}_edge.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          class Types::#{singularized_class_name.camelize}Edge < Types::BaseEdge
            node_type(Types::#{singularized_class_name.camelize}Type)
          end
        TEXT
      end
      SOULs::Painter.create_file(file_path.to_s)
      file_path
    end
  end
end
