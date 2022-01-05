module SOULs
  class Update < Thor
    desc "create_mutation_rbs [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def create_mutation_rbs(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = ""
      Dir.chdir(SOULs.get_api_path.to_s) do
        new_cols = SOULs.get_columns_num(class_name: singularized_class_name)
      end
      dir_name = "./sig/api/app/graphql/mutations/base/#{singularized_class_name}"
      file_path = "#{dir_name}/create_#{singularized_class_name}.rbs"
      argument = false
      resolve = false
      write_txt = ""
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          next if line.include?("| (:") && argument

          if line.include?("{ :node => String } } | ::GraphQL::ExecutionError )")
            write_txt += line
            resolve = false
          elsif resolve
            next
          elsif line.include?("def resolve:") && !resolve
            new_cols.each_with_index do |col, i|
              type = SOULs.type_check(col[:type])
              type = "[#{type}]" if col[:array]
              next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

              write_txt +=
                if i.zero?
                  line
                else
                  "                          #{col[:column_name]}: #{type}?,\n"
                end
            end
            resolve = true
          elsif line.include?("def self.argument:") && !argument
            new_cols.each_with_index do |col, i|
              type = SOULs.type_check(col[:type])
              type = "[#{type}]" if col[:array]
              next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

              if i.zero?
                write_txt +=
                  "        def self.argument: (:#{col[:column_name]}, #{type}, required: false ) -> #{type}\n"
              else
                write_txt +=
                  "                         | (:#{col[:column_name]}, #{type}, required: false ) -> #{type}\n"
              end
            end
            argument = true
          else
            write_txt += line
          end
        end
      end
      File.open(file_path, "w") { |f| f.write(write_txt) }
      SOULs::Painter.update_file(file_path.to_s)
    end

    desc "update_mutation [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def update_mutation_rbs(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = ""
      Dir.chdir(SOULs.get_api_path.to_s) do
        new_cols = SOULs.get_columns_num(class_name: singularized_class_name)
      end
      dir_name = "./sig/api/app/graphql/mutations/base/#{singularized_class_name}"
      new_file_path = "config/update_mutation.rbs"
      file_path = "#{dir_name}/update_#{singularized_class_name}.rbs"
      argument = false
      resolve = false
      File.open(file_path) do |f|
        File.open(new_file_path, "w") do |new_line|
          f.each_line do |line|
            next if line.include?("| (:") && argument

            if line.include?("{ :node => String } } | ::GraphQL::ExecutionError )")
              new_line.write(line)
              resolve = false
            elsif resolve
              next
            elsif line.include?("def resolve:") && !resolve
              new_cols.each_with_index do |col, i|
                type = SOULs.type_check(col[:type])
                type = "[#{type}]" if col[:array]
                next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

                if i.zero?
                  new_line.write(line)
                  new_line.write("                          id: String,\n")
                else
                  new_line.write("                          #{col[:column_name]}: #{type}?,\n")
                end
              end
              resolve = true
            elsif line.include?("def self.argument:") && !argument
              new_cols.each_with_index do |col, i|
                type = SOULs.type_check(col[:type])
                type = "[#{type}]" if col[:array]
                next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

                if i.zero?
                  new_line.write(
                    "        def self.argument: (:#{col[:column_name]}, #{type}, required: false ) -> #{type}\n"
                  )
                else
                  new_line.write(
                    "                         | (:#{col[:column_name]}, #{type}, required: false ) -> #{type}\n"
                  )
                end
              end
              argument = true
            else
              new_line.write(line)
            end
          end
        end
      end
      FileUtils.rm(file_path)
      FileUtils.mv(new_file_path, file_path)
      SOULs::Painter.update_file(file_path.to_s)
    end
  end
end
