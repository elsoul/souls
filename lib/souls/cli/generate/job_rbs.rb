module SOULs
  class Generate < Thor
    desc "job_rbs [CLASS_NAME]", "Generate SOULs Job Mutation RBS Template"
    def job_rbs(class_name)
      file_path = ""
      worker_name = FileUtils.pwd.split("/").last
      Dir.chdir(SOULs.get_mother_path.to_s) do
        singularized_class_name = class_name.underscore.singularize
        file_dir = "./sig/#{worker_name}/app/graphql/queries/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}#{singularized_class_name}.rbs"
        sig_type_path = "./sig/#{worker_name}/app/graphql/types"
        FileUtils.mkdir_p(sig_type_path) unless Dir.exist?(sig_type_path)
        type_file_path = "#{sig_type_path}/#{singularized_class_name}_type.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Queries
              class #{singularized_class_name.camelize} < BaseQuery
                def self.description: (String) -> untyped
                def self.field: (:response, String, null: false) -> untyped
                def self.type: (untyped, null: false) -> untyped
              end
            end
          TEXT
        end
        File.open(type_file_path, "w") do |f|
          f.write(<<~TEXT)
            module Types
              class #{singularized_class_name.camelize}Type < SOULs::Types::BaseObject
                def self.field: (:response, String, null: true) -> untyped
              end
            end
          TEXT
        end
        SOULs::Painter.create_file(file_path.to_s)
      end
      file_path
    end
  end
end
