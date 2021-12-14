module Souls
  class Delete < Thor
    desc "rspec_factory [CLASS_NAME]", "Delete Rspec Factory Test from schema.rb"
    def rspec_factory(class_name)
      file_path = "./spec/factories/#{class_name.pluralize}.rb"
      FileUtils.rm_f(file_path)
      Souls::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
