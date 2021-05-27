module Souls
  module Generate
    class << self
      ## Generate Resolver
      def resolver_head class_name: "souls"
        FileUtils.mkdir_p "./app/graphql/resolvers" unless Dir.exist? "./app/graphql/resolvers"
        file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
        return "Resolver already exist! #{file_path}" if File.exist? file_path
        @relation_params = []
        return ["Resolver already exist! #{file_path}"] if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Resolvers
              class #{class_name.camelize}Search < Base
                include SearchObject.module(:graphql)
                scope { ::#{class_name.camelize}.all }
                type Types::#{class_name.camelize}Type.connection_type, null: false
                description "Search #{class_name.camelize}"

                class #{class_name.camelize}Filter < ::Types::BaseInputObject
                  argument :OR, [self], required: false
          EOS
        end
      end

      def resolver_params class_name: "souls"
        file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  break
                end
                field = "[String]" if line.include?("array: true")
                type, name = get_type_and_name(line)
                field ||= type_check type
                case name
                when "user_id"
                  @user_exist = true
                when /$*_id\z/
                  @relation_params << name
                  new_line.write "      argument :#{name}, String, required: false\n"
                when "created_at", "updated_at"
                  next
                else
                  new_line.write "      argument :#{name}, #{field}, required: false\n"
                end
              end
              @on = true if table_check(line: line, class_name: class_name)
            end
          end
        end
      end

      def resolver_after_params class_name: "souls"
        file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
        File.open(file_path, "a") do |f|
          f.write <<-EOS
      argument :start_date, String, required: false
      argument :end_date, String, required: false
    end

    option :filter, type: #{class_name.camelize}Filter, with: :apply_filter
    option :first, type: types.Int, with: :apply_first
    option :skip, type: types.Int, with: :apply_skip

    def apply_filter(scope, value)
      branches = normalize_filters(value).inject { |a, b| a.or(b) }
      scope.merge branches
    end

    def normalize_filters(value, branches = [])
      scope = ::#{class_name.camelize}.all
          EOS
        end
      end

      def resolver_before_end class_name: "souls"
        file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  break
                end
                type, name = get_type_and_name(line)
                if line.include?("array: true")
                  new_line.write "      scope = scope.where(\"#{name} @> ARRAY[?]::text[]\", value[:#{name}]) if value[:#{name}]\n"
                  next
                end
                case name
                when "user_id"
                  @user_exist = true
                when /$*_id\z/
                  @relation_params << name
                  new_line.write "      scope = scope.where(#{name}: decode_global_key(value[:#{name}])) if value[:#{name}]\n"
                when "created_at", "updated_at"
                  next
                else
                  case type
                  when "boolean"
                    new_line.write "      scope = scope.where(#{name}: value[:#{name}]) unless value[:#{name}].nil?\n"
                  else
                    new_line.write "      scope = scope.where(#{name}: value[:#{name}]) if value[:#{name}]\n"
                  end
                end
              end
              @on = true if table_check(line: line, class_name: class_name)
            end
          end
        end
      end

      def resolver_end class_name: "souls"
        file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
        File.open(file_path, "a") do |f|
          f.write <<~EOS
                              scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
                              scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]
            #{'            '}
                              branches << scope
            #{'            '}
                              value[:OR].inject(branches) { |s, v| normalize_filters(v, s) } if value[:OR].present?
            #{'            '}
                              branches
                            end
                          end
                        end
          EOS
        end
        file_path
      end

      def resolver class_name: "souls"
        singularized_class_name = class_name.singularize.underscore
        resolver_head class_name: singularized_class_name
        resolver_params class_name: singularized_class_name
        resolver_after_params class_name: singularized_class_name
        resolver_before_end class_name: singularized_class_name
        resolver_end class_name: singularized_class_name
      end
    end
  end
end
