require_relative "../cli_exception"

module Souls
  class Update < Thor
    desc "create_mutation [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def create_mutation(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = Souls.get_columns_num(class_name: singularized_class_name)
      dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
      file_path = "#{dir_name}/create_#{singularized_class_name}.rb"
      raise Souls::CLIException.new("File #{file_path} is missing. Please recreate it and then run this command again.") unless
        File.exist? file_path
      write_txt = String.new
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          write_txt << line
          next if new_cols.empty? || !line.strip.start_with?("argument")

          until new_cols.empty?
            col = new_cols.pop
            type = Souls.type_check(col[:type])
            type = "[#{type}]" if col[:array]
            args = check_mutation_argument(class_name: class_name)
            next if args.include?(col[:column_name])
            next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

            write_txt << "      argument :#{col[:column_name]}, #{type}, required: false\n"
          end
        end
      end
      File.open(file_path, "w") { |f| f.write(write_txt) }
      puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
    end

    desc "update_mutation [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def update_mutation(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = Souls.get_columns_num(class_name: singularized_class_name)
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
              type = Souls.type_check(col[:type])
              type = "[#{type}]" if col[:array]
              args = check_mutation_argument(class_name: class_name, action: "update")
              next if args.include?(col[:column_name])
              next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

              new_line.write("      argument :#{col[:column_name]}, #{type}, required: false\n")
            end
            argument = true
          end
        end
      end
      FileUtils.rm(file_path)
      FileUtils.mv(new_file_path, file_path)
      puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
    end

    private

    def check_mutation_argument(class_name: "user", action: "create")
      singularized_class_name = class_name.singularize.underscore
      dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
      file_path = "#{dir_name}/#{action}_#{singularized_class_name}.rb"
      args = []
      File.open(file_path) do |f|
        f.each_line do |line|
          args << line.split(",")[0].gsub("argument :", "").strip.underscore if line.include?("argument")
        end
      end
      args
    end
  end
end
