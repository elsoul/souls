module Souls
  class Generate < Thor
    desc "resolver [CLASS_NAME]", "Generate GraphQL Resolver from schema.rb"
    def resolver(class_name)
      singularized_class_name = class_name.singularize.underscore
      file_path = "./app/graphql/resolvers/#{singularized_class_name}_search.rb"
      raise(StandardError, "Resolver already exist! #{file_path}") if File.exist?(file_path)

      resolver_head(class_name: singularized_class_name)
      resolver_params(class_name: singularized_class_name)
      resolver_after_params(class_name: singularized_class_name)
      resolver_before_end(class_name: singularized_class_name)
      resolver_end(class_name: singularized_class_name)
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    private

    def resolver_head(class_name: "user")
      FileUtils.mkdir_p("./app/graphql/resolvers") unless Dir.exist?("./app/graphql/resolvers")
      file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
      @relation_params = []
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Resolvers
            class #{class_name.camelize}Search < BaseResolver
              include SearchObject.module(:graphql)
              scope { ::#{class_name.camelize}.all }
              type Types::#{class_name.camelize}Type.connection_type, null: false
              description "Search #{class_name.camelize}"

              class #{class_name.camelize}Filter < Souls::Types::BaseInputObject
                argument :OR, [self], required: false
        TEXT
      end
    end

    def resolver_params(class_name: "user")
      file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
      path = "./db/schema.rb"
      @on = false
      @user_exist = false
      @relation_params = []
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              break if line.include?("t.index") || line.strip == "end"

              field = "[String]" if line.include?("array: true")
              type, name = Souls.get_type_and_name(line)
              field ||= Souls.type_check(type)
              case name
              when "user_id"
                @user_exist = true
              when /$*_id\z/
                @relation_params << name
                new_line.write("      argument :#{name}, String, required: false\n")
              when "created_at", "updated_at"
                next
              else
                new_line.write("      argument :#{name}, #{field}, required: false\n")
              end
            end
            @on = true if Souls.table_check(line: line, class_name: class_name)
          end
        end
      end
    end

    def resolver_after_params(class_name: "user")
      file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
      File.open(file_path, "a") do |f|
        f.write(<<-TEXT)
        argument :start_date, String, required: false
        argument :end_date, String, required: false
      end

      option :filter, type: #{class_name.camelize}Filter, with: :apply_filter

      def apply_filter(scope, value)
        branches = normalize_filters(value).inject { |a, b| a.or(b) }
        scope.merge branches
      end

      def normalize_filters(value, branches = [])
        scope = ::#{class_name.camelize}.all
        TEXT
      end
    end

    def resolver_before_end(class_name: "user")
      file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
      path = "./db/schema.rb"
      @on = false
      @user_exist = false
      @relation_params = []
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              break if line.include?("t.index") || line.strip == "end"

              type, name = Souls.get_type_and_name(line)
              if line.include?("array: true")
                new_line.write(
                  "      scope = scope.where(\"#{name} @> ARRAY[?]::text[]\", value[:#{name}]) if value[:#{name}]\n"
                )
                next
              end
              case name
              when "user_id"
                @user_exist = true
              when /$*_id\z/
                @relation_params << name
                new_line.write(
                  "      scope = scope.where(#{name}: decode_global_key(value[:#{name}])) if value[:#{name}]\n"
                )
              when "created_at", "updated_at"
                next
              else
                case type
                when "boolean"
                  new_line.write("      scope = scope.where(#{name}: value[:#{name}]) unless value[:#{name}].nil?\n")
                else
                  new_line.write("      scope = scope.where(#{name}: value[:#{name}]) if value[:#{name}]\n")
                end
              end
            end
            @on = true if Souls.table_check(line: line, class_name: class_name)
          end
        end
      end
    end

    def resolver_end(class_name: "user")
      file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
      File.open(file_path, "a") do |f|
        f.write(<<~TEXT)
                scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
                scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]
                branches << scope.order(created_at: :desc)
                value[:OR].inject(branches) { |s, v| normalize_filters(v, s) } if value[:OR].present?
                branches
              end
            end
          end
        TEXT
      end
      file_path
    end
  end
end
