module Souls
  module Generate
    class << self
      ## Generate Model
      def model class_name: "souls"
        file_dir = "./app/models/"
        FileUtils.mkdir_p file_dir unless Dir.exist? file_dir
        file_path = "#{file_dir}#{class_name.singularize}.rb"
        return "Model already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            class #{class_name.camelize} < ActiveRecord::Base
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
