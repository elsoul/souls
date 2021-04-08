module Souls
  module Generate
    class << self
      ## Generate Model
      def model class_name: "souls"
        file_path = "./app/models/#{class_name.singularize}.rb"
        return "Model already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            class #{class_name.camelize} < ActiveRecord::Base
            end
          EOS
        end
        file_path
      end
    end
  end
end
