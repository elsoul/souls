module Souls
  class Generate < Thor
    desc "edge", "Generate GraphQL Edge from schema.rb"
    def edge(class_name: "user")
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
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue StandardError => e
      raise(StandardError, e)
    end
  end
end
