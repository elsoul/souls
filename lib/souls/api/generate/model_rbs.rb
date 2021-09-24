module Souls
  class Generate < Thor
    desc "model_rbs [CLASS_NAME]", "Generate GraphQL Model RBS from schema.rb"
    def model_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types/models/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}_model.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Types
              class #{singularized_class_name.camelize} < ActiveRecord::Base
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
