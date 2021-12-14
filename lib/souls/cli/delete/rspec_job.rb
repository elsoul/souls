module Souls
  class Delete < Thor
    desc "rspec_job [CLASS_NAME]", "Delete Rspec Job Test Template"
    def rspec_job(class_name)
      file_dir = "./spec/jobs"
      singularized_class_name = class_name.underscore.singularize
      file_path = "#{file_dir}/#{singularized_class_name}_spec.rb"
      FileUtils.rm_f(file_path)
      Souls::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
