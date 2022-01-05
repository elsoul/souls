module SOULs
  class DB < Thor
    desc "model_rbs [CLASS_NAME]", "Generate GraphQL Model RBS from schema.rb"
    def model_rbs(class_name)
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/models/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            class #{singularized_class_name.camelize} < ActiveRecord::Base
            end
          TEXT
        end
        SOULs::Painter.create_file(file_path.to_s)
      end
      file_path
    end
  end
end
