module Souls
  module Api
    module Update
      class << self
        def type(class_name: "user")
          singularized_class_name = class_name.singularize.underscore
          new_cols = Souls.get_columns_num(class_name: singularized_class_name)
          dir_name = "./app/graphql/types"
          new_file_path = "tmp/create_type.rb"
          file_path = "#{dir_name}/#{singularized_class_name}_type.rb"
          argument = false
          File.open(file_path) do |f|
            File.open(new_file_path, "w") do |new_line|
              f.each_line do |line|
                new_line.write(line)
                next unless line.include?("field") && !argument

                new_cols.each do |col|
                  type = Souls::Api::Generate.get_type(col[:type])
                  type = "[#{type}]" if col[:array]
                  args = check_type_argument(class_name: class_name)
                  unless args.include?(col[:column_name])
                    new_line.write("    field :#{col[:column_name]}, #{type}, null: true\n")
                  end
                end
                argument = true
              end
            end
          end
          FileUtils.rm(file_path)
          FileUtils.mv(new_file_path, file_path)
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        end

        def check_type_argument(class_name: "user")
          singularized_class_name = class_name.singularize.underscore
          dir_name = "./app/graphql/types"
          file_path = "#{dir_name}/#{singularized_class_name}_type.rb"
          args = []
          File.open(file_path) do |f|
            f.each_line do |line|
              args << line.split(",")[0].gsub("field :", "").strip if line.include?(" field :")
            end
          end
          args
        end
      end
    end
  end
end
