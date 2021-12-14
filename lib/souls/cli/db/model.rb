module Souls
  class DB < Thor
    desc "model [CLASS_NAME]", "Generate Model Template"
    def model(class_name)
      file_dir = "./app/models/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      return "Model already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          class #{class_name.camelize} < ActiveRecord::Base
          end
        TEXT
      end
      Souls::Painter.create_file(file_path.to_s)
      file_path
    end
  end
end
