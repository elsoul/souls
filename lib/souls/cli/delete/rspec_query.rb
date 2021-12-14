module Souls
  class Delete < Thor
    desc "rspec_query [CLASS_NAME]", "Delete Rspec Query Test"
    def rspec_query(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./spec/queries/#{singularized_class_name}_spec.rb"
      FileUtils.rm_f(file_path)
      Souls::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
