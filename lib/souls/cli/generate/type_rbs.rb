module Souls
  class Generate < Thor
    desc "type_rbs [CLASS_NAME]", "Generate GraphQL Type RBS from schema.rb"
    def type_rbs(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/#{singularized_class_name}_type.rbs"
        raise(Thor::Error, "Type RBS already exist! #{file_path}") if File.exist?(file_path)

        params = Souls.get_relation_params(class_name: singularized_class_name)
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Types
              class #{singularized_class_name.camelize}Type < BaseObject
                def self.implements: (*untyped) -> untyped
                def self.global_id_field: (:id) -> String
          TEXT
        end
        File.open(file_path, "a") do |f|
          params[:params].each_with_index do |param, i|
            type = Souls.type_check(param[:type])
            type = "[#{type}]" if param[:array]
            rbs_type = Souls.rbs_type_check(param[:type])
            if i.zero?
              f.write("    def self.field: (:#{param[:column_name]}, #{type}, null: true) -> #{rbs_type}\n")
            else
              f.write("                  | (:#{param[:column_name]}, #{type}, null: true) -> #{rbs_type}\n")
            end
          end
        end

        File.open(file_path, "a") do |f|
          f.write(<<~TEXT)
              def self.edge_type: () -> void
                def self.connection_type: () -> void
              end
            end
          TEXT
        end
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
