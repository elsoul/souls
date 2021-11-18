module Souls
  class Update < Thor
    desc "type_rbs [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def type_rbs(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = ""
      Dir.chdir(Souls.get_api_path.to_s) do
        new_cols = Souls.get_columns_num(class_name: singularized_class_name)
      end
      dir_name = "./sig/api/app/graphql/types"
      new_file_path = "config/create_type.rbs"
      file_path = "#{dir_name}/#{singularized_class_name}_type.rbs"
      argument = false
      File.open(file_path) do |f|
        File.open(new_file_path, "w") do |new_line|
          f.each_line do |line|
            next if line.include?("| (:") && argument

            if line.include?("    def self.edge_type:")
              new_line.write(line)
              argument = false
            elsif line.include?("def self.field:") && !argument
              new_cols.each_with_index do |col, i|
                type = Souls.get_type(col[:type])
                type = "[#{type}]" if col[:array]
                if i.zero?
                  new_line.write("    def self.field: (:#{col[:column_name]}, #{type}, null: true) -> #{type}\n")
                else
                  new_line.write("                  | (:#{col[:column_name]}, #{type}, null: true) -> #{type}\n")
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
      puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
    end
  end
end
