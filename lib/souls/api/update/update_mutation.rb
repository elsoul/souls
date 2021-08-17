module Souls
  module Api
    module Update
      class << self
        def update_create_mutation(class_name: "user")
          singularized_class_name = class_name.singularize.underscore
          new_cols = Souls.get_last_migration_type(class_name: singularized_class_name, action: "add")
          dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
          new_file_path = "tmp/create_mutation.rb"
          file_path = "#{dir_name}/create_#{singularized_class_name}.rb"
          argument = false
          File.open(file_path) do |f|
            File.open(new_file_path, "w") do |new_line|
              f.each_line do |line|
                new_line.write(line)
                next unless line.include?("argument") && !argument

                new_cols.each do |col|
                  type = col[:array] ? "[#{col[:type].camelize}]" : col[:type].camelize
                  args = check__mutation_argument(class_name: class_name)
                  unless args.include?(col[:column_name])
                    new_line.write("      argument :#{col[:column_name]}, #{type}, required: false\n")
                  end
                end
                argument = true
              end
            end
          end
          # FileUtils.rm(file_path)
          # FileUtils.mv(new_file_path, file_path)
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        end

        def update_update_mutation(class_name: "user")
          singularized_class_name = class_name.singularize.underscore
          new_cols = Souls.get_last_migration_type(class_name: singularized_class_name, action: "add")
          dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
          new_file_path = "tmp/update_mutation.rb"
          file_path = "#{dir_name}/update_#{singularized_class_name}.rb"
          argument = false
          File.open(file_path) do |f|
            File.open(new_file_path, "w") do |new_line|
              f.each_line do |line|
                new_line.write(line)
                next unless line.include?("argument") && !argument

                new_cols.each do |col|
                  type = col[:array] ? "[#{col[:type].camelize}]" : col[:type].camelize
                  args = check__mutation_argument(class_name: class_name, action: "update")
                  unless args.include?(col[:column_name])
                    new_line.write("      argument :#{col[:column_name]}, #{type}, required: false\n")
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

        def check__mutation_argument(class_name: "user", action: "create")
          singularized_class_name = class_name.singularize.underscore
          dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
          file_path = "#{dir_name}/#{action}_#{singularized_class_name}.rb"
          args = []
          File.open(file_path) do |f|
            f.each_line do |line|
              args << line.split(",")[0].gsub("argument :", "").strip if line.include?("argument")
            end
          end
          args
        end
      end
    end
  end
end
