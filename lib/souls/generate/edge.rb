module Souls
  module Generate
    class << self
      def edge class_name: "souls"
        singularized_class_name = class_name.underscore.singularize
        file_path = "./app/graphql/types/edges/#{singularized_class_name}_edge.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            class Types::#{singularized_class_name.camelize}Edge < Types::BaseEdge
              node_type(Types::#{singularized_class_name.camelize}Type)
            end
          EOS
        end
        puts Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }]
        file_path
      rescue StandardError => e
        raise StandardError, e
      end
    end
  end
end
