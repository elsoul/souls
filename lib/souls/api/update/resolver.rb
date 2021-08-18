module Souls
  module Api
    module Update
      class << self
        def resolver(class_name: "user")
          singularized_class_name = class_name.singularize.underscore
          new_cols = Souls.get_columns_num(class_name: singularized_class_name)
          dir_name = "./app/graphql/resolvers"
          new_file_path = "tmp/update_resolver.rb"
          file_path = "#{dir_name}/#{singularized_class_name}_search.rb"
          args = check_resolver_argument(class_name: class_name)
          scope_args = check_resolver_argument(class_name: class_name, action: "scope")
          argument = false
          scope = false
          File.open(file_path) do |f|
            File.open(new_file_path, "w") do |new_line|
              f.each_line do |line|
                new_line.write(line)
                if line.include?("argument") && !argument
                  new_cols.each do |col|
                    type = Souls::Api::Generate.type_check(col[:type])
                    type = "[#{type}]" if col[:array]
                    add_line = "      argument :#{col[:column_name]}, #{type}, required: false\n"
                    new_line.write(add_line) unless args.include?(col[:column_name])
                  end
                  argument = true
                elsif line.include?("scope = ::") && !scope
                  new_cols.each do |col|
                    type = Souls::Api::Generate.type_check(col[:type])
                    type = "[#{type}]" if col[:array]

                    if type.include?("[")
                      add_line = "      scope = scope.where('#{col[:column_name]} @> ARRAY[?]::#{col[:type]}[]', value[:#{col[:column_name]}]) if value[:#{col[:column_name]}]\n"
                    else
                      add_line = "      scope = scope.where(#{col[:column_name]}: value[:#{col[:column_name]}]) if value[:#{col[:column_name]}]\n"
                    end
                    new_line.write(add_line) unless scope_args.include?(col[:column_name])
                  end
                  scope = true
                end
              end
            end
          end
          FileUtils.rm(file_path)
          FileUtils.mv(new_file_path, file_path)
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        rescue StandardError => e
          p(e.backtrace)
        end

        def check_resolver_argument(class_name: "user", action: "argument")
          singularized_class_name = class_name.singularize.underscore
          dir_name = "./app/graphql/resolvers"
          file_path = "#{dir_name}/#{singularized_class_name}_search.rb"
          args = []
          File.open(file_path) do |f|
            f.each_line do |line|
              if action == "scope" && line.include?("scope = scope.where")
                args << if line.include?("is_deleted")
                          "is_deleted"
                        else
                          line.to_s.match(/if value\[:(.+)\]/)[1].underscore
                        end
              elsif action == "argument" && line.include?("argument")
                args << line.split(",")[0].gsub("argument :", "").strip.underscore
              end
            end
          end
          args
        end
      end
    end
  end
end
