module Souls
  module Api
    module Update
      class << self
        def rspec_factory(class_name: "user")
          singularized_class_name = class_name.singularize.underscore
          pluralized_class_name = class_name.pluralize.underscore
          new_cols = Souls.get_columns_num(class_name: singularized_class_name)
          dir_name = "./spec/factories"
          new_file_path = "tmp/create_factory.rb"
          file_path = "#{dir_name}/#{pluralized_class_name}.rb"
          argument = false
          File.open(file_path) do |f|
            File.open(new_file_path, "w") do |new_line|
              f.each_line do |line|
                new_line.write(line)
                next unless line.include?("{") && !argument

                new_cols.each do |col|
                  next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

                  type = Souls.get_test_type(col[:type])
                  type = "[#{type}]" if col[:array]
                  args = check_factory_argument(class_name: class_name)

                  new_line.write("    #{col[:column_name]} { #{type} }\n") unless args.include?(col[:column_name])
                end
                argument = true
              end
            end
          end
          FileUtils.rm(file_path)
          FileUtils.mv(new_file_path, file_path)
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        end

        def check_factory_argument(class_name: "user")
          pluralized_class_name = class_name.pluralize.underscore
          dir_name = "./spec/factories"
          file_path = "#{dir_name}/#{pluralized_class_name}.rb"
          args = []
          File.open(file_path) do |f|
            f.each_line do |line|
              args << line.split("{")[0].strip.underscore if line.include?("{")
            end
          end
          args
        end
      end
    end
  end
end
