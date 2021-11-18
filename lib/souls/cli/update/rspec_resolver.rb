module Souls
  class Update < Thor
    desc "rspec_resolver [CLASS_NAME]", "Update GraphQL Type from schema.rb"
    def rspec_resolver(class_name)
      singularized_class_name = class_name.singularize.underscore
      new_cols = Souls.get_columns_num(class_name: singularized_class_name)
      dir_name = "./spec/resolvers"
      new_file_path = "tmp/rspec_resolver.rb"
      file_path = "#{dir_name}/#{singularized_class_name}_search_spec.rb"
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

            if node_res && !line.include?("{")
              node_args = check_rspec_resolver_argument(class_name: class_name, action: "node_args")
              new_cols.each do |col|
                unless node_args.include?(col[:column_name])
                  new_line.write("              #{col[:column_name].camelize(:lower)}\n")
                end
              end
              node_res = false
            elsif test_res && line.include?("=> be_")
              test_args = check_rspec_resolver_argument(class_name: class_name, action: "test_args")
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
                  new_line.write("          \"#{col[:column_name].camelize(:lower)}\" => #{text},\n")
                end
              end
              test_res = false
            end
          end
        end
      end
      FileUtils.rm(file_path)
      FileUtils.mv(new_file_path, file_path)
      puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
    end

    private

    def check_rspec_resolver_argument(class_name: "user", action: "node_args")
      singularized_class_name = class_name.singularize.underscore
      dir_name = "./spec/resolvers"
      file_path = "#{dir_name}/#{singularized_class_name}_search_spec.rb"
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
