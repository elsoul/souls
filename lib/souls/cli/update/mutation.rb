require_relative "../cli_exception"

module SOULs
  class Update < Thor
    desc "create_mutation [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def create_mutation(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = SOULs.get_columns_num(class_name: singularized_class_name)
      dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
      file_path = "#{dir_name}/create_#{singularized_class_name}.rb"
      unless File.exist?(file_path)
        SOULs::Painter.error("File #{file_path} is missing. Please recreate it and then run this command again.")
        return
      end

      mutation_argument = check_mutation_argument(class_name: "user", action: "create")
      overwrite_class_file(mutation_argument: mutation_argument, file_path: file_path, new_cols: new_cols)
      SOULs::Painter.update_file(file_path.to_s)
    end

    desc "update_mutation [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def update_mutation(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = SOULs.get_columns_num(class_name: singularized_class_name)
      dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
      file_path = "#{dir_name}/update_#{singularized_class_name}.rb"
      unless File.exist?(file_path)
        SOULs::Painter.error("File #{file_path} is missing. Please recreate it and then run this command again.")
        return
      end

      mutation_argument = check_mutation_argument(class_name: class_name, action: "update")
      overwrite_class_file(mutation_argument: mutation_argument, file_path: file_path, new_cols: new_cols)

      SOULs::Painter.update_file(file_path.to_s)
    end

    private

    def overwrite_class_file(mutation_argument: "arg", file_path: "path", new_cols: 1)
      write_txt = String.new
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          write_txt << line
          next if new_cols.empty? || !line.strip.start_with?("argument")

          until new_cols.empty?
            col = new_cols.pop
            type = SOULs.type_check(col[:type])
            type = "[#{type}]" if col[:array]
            args = mutation_argument
            next if args.include?(col[:column_name])
            next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

            write_txt << "      argument :#{col[:column_name]}, #{type}, required: false\n"
          end
        end
      end
      File.open(file_path, "w") { |f| f.write(write_txt) }
    end

    def check_mutation_argument(class_name: "user", action: "action")
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
