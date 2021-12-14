module Souls
  class Update < Thor
    desc "rspec_mutation [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def rspec_mutation(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = Souls.get_columns_num(class_name: singularized_class_name)
      dir_name = "./spec/mutations/base"
      new_file_path = "tmp/rspec_mutation.rb"
      file_path = "#{dir_name}/#{singularized_class_name}_spec.rb"
      argument = false
      node_res = false
      test_res = false
      File.open(file_path) do |f|
        File.open(new_file_path, "w") do |new_line|
          f.each_line do |line|
            new_line.write(line)
            node_res = true if line.include?("node {")
            test_res = true if line.include?("include(")
            node_res = false if node_res && line.include?("}")
            test_res = false if test_res && line.strip == ")"

            if line.include?('#{') && !argument
              new_cols.each do |col|
                type = Souls.type_check(col[:type])
                next if col[:column_name] == "created_at" || col[:column_name] == "updated_at"

                type_line =
                  if type == "String" && !col[:array]
                    "          #{col[:column_name].camelize(:lower)}" \
                    ": \"\#{#{class_name}[:#{col[:column_name].underscore}]}\"\n"
                  else
                    "          #{col[:column_name].camelize(:lower)}" \
                    ": \#{#{class_name}[:#{col[:column_name].underscore}]}\n"
                  end
                args = check_rspec_mutation_argument(class_name: class_name)
                new_line.write(type_line) unless args.include?(col[:column_name].underscore)
              end
              argument = true
            elsif node_res && !line.include?("{")
              node_args = check_rspec_mutation_argument(class_name: class_name, action: "node_args")
              new_cols.each do |col|
                unless node_args.include?(col[:column_name])
                  new_line.write("              #{col[:column_name].camelize(:lower)}\n")
                end
              end
              node_res = false
            elsif test_res && line.include?("=> be_")
              test_args = check_rspec_mutation_argument(class_name: class_name, action: "test_args")
              new_cols.each do |col|
                type = Souls.type_check(col[:type])
                text =
                  case type
                  when "Integer", "Float"
                    col[:array] ? "be_all(Integer)" : "be_a(Integer)"
                  when "Boolean"
                    col[:array] ? "be_all([true, false])" : "be_in([true, false])"
                  else
                    col[:array] ? "be_all(String)" : "be_a(String)"
                  end
                unless test_args.include?(col[:column_name])
                  new_line.write("        \"#{col[:column_name].camelize(:lower)}\" => #{text},\n")
                end
              end
              test_res = false
            end
          end
        end
      end
      FileUtils.rm(file_path)
      FileUtils.mv(new_file_path, file_path)
      Souls::Painter.update_file(file_path.to_s)
    end

    private

    def check_rspec_mutation_argument(class_name: "user", action: "argument")
      singularized_class_name = class_name.singularize.underscore
      dir_name = "./spec/mutations/base"
      file_path = "#{dir_name}/#{singularized_class_name}_spec.rb"
      node_res = false
      test_res = false
      args = []
      File.open(file_path) do |f|
        f.each_line do |line|
          node_res = true if line.include?("node {")
          test_res = true if line.include?("include(")
          node_res = false if node_res && line.include?("}")
          test_res = false if test_res && line.strip == ")"
          if action == "node_args"
            args << line.strip.underscore if node_res && !line.include?("{")
          elsif action == "test_args"
            args << line.split("\"")[1].underscore if test_res && line.include?("=> be_")
          elsif line.include?('#{')
            args << line.split(":")[0].strip.underscore
          end
        end
      end
      args
    end
  end
end
