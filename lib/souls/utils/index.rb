module Souls
  module Utils
    def get_mother_path
      FileUtils.pwd.split(Souls.configuration.app)[0] + Souls.configuration.app
    end

    def get_api_path
      FileUtils.pwd.split(Souls.configuration.app)[0] + Souls.configuration.app + "/apps/api"
    end

    def type_check(type)
      {
        bigint: "Integer",
        string: "String",
        float: "Float",
        text: "String",
        datetime: "String",
        date: "String",
        boolean: "Boolean",
        integer: "Integer"
      }[type.to_sym]
    end

    def get_type_and_name(line)
      line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
    end

    def get_type(type)
      {
        bigint: "Integer",
        string: "String",
        float: "Float",
        text: "String",
        datetime: "GraphQL::Types::ISO8601DateTime",
        date: "GraphQL::Types::ISO8601DateTime",
        boolean: "Boolean",
        integer: "Integer"
      }[type.to_sym]
    end

    def get_test_type(type)
      {
        bigint: "rand(1..10)",
        float: 4.2,
        string: '"MyString"',
        text: '"MyString"',
        datetime: "Time.now",
        date: "Time.now.strftime('%F')",
        boolean: false,
        integer: "rand(1..10)"
      }[type.to_sym]
    end

    def get_tables
      path = "./db/schema.rb"
      tables = []
      File.open(path, "r") do |f|
        f.each_line.with_index do |line, _i|
          tables << line.split("\"")[1] if line.include?("create_table")
        end
      end
      tables
    end

    def table_check(line: "", class_name: "")
      if line.include?("create_table") && (line.split[1].gsub("\"", "").gsub(",", "") == class_name.pluralize.to_s)

        return true
      end

      false
    end

    def version_detector(current_ver: [0, 0, 1], update_kind: "patch")
      case update_kind
      when "patch"
        "#{current_ver[0]}.#{current_ver[1]}.#{current_ver[2] + 1}"
      when "minor"
        "#{current_ver[0]}.#{current_ver[1] + 1}.0"
      when "major"
        "#{current_ver[0] + 1}.0.0"
      else
        raise(StandardError, "Wrong version!")
      end
    end

    def get_latest_version_txt(service_name: "api")
      case service_name
      when "gem"
        return Souls::VERSION.split(".").map(&:to_i)
      when "api", "worker", "console", "admin", "media"
        file_path = "#{Gem.dir}/gems/souls-#{Souls::VERSION}/lib/souls/versions/.souls_#{service_name}_version"
      else
        raise(StandardError, "You are at wrong directory!")
      end
      File.open(file_path, "r") do |f|
        f.readlines[0].strip.split(".").map(&:to_i)
      end
    end

    def get_columns_num(class_name: "user")
      file_path = "./db/schema.rb"
      class_check_flag = false
      cols = []
      File.open(file_path, "r") do |f|
        f.each_line.with_index do |line, _i|
          class_check_flag = true if line.include?("create_table") && line.include?(class_name)
          if class_check_flag == true && !line.include?("create_table")
            return cols if line.include?("t.index") || line.strip == "end"

            types = Souls.get_type_and_name(line)
            array = line.include?("array: true")
            cols << { column_name: types[1], type: types[0], array: array }
          end
        end
      end
      cols
    end

    def get_create_migration_type(class_name: "user")
      pluralized_class_name = class_name.pluralize
      file_path = Dir["db/migrate/*_create_#{pluralized_class_name}.rb"][0]

      class_check_flag = false
      response = [
        { column_name: "created_at", type: "datetime", array: false },
        { column_name: "updated_at", type: "datetime", array: false }
      ]
      File.open(file_path) do |f|
        f.each_line do |line|
          class_check_flag = true if line.include?("create_table")
          next unless class_check_flag == true && !line.include?("create_table")
          return response if line.include?("t.timestamps") || line.strip == "end"

          types = Souls.get_type_and_name(line)
          types.map { |n| n.gsub!(":", "") }
          array = line.include?("array: true")
          response << { column_name: types[1], type: types[0], array: array }
        end
      end
    end

    def get_migration_type(class_name: "user", action: "add")
      pluralized_class_name = class_name.pluralize
      file_paths = Dir["db/migrate/*_#{action}_column_to_#{pluralized_class_name}.rb"]

      new_columns =
        file_paths.map do |file_path|
          get_col_name_and_type(class_name: class_name, file_path: file_path, action: action)
        end
      new_columns.flatten
    end

    def get_col_name_and_type(
      class_name: "user", file_path: "db/migrate/20210816094410_add_column_to_users.rb", action: "add"
    )
      pluralized_class_name = class_name.pluralize
      response = []
      File.open(file_path) do |line|
        line.each_line do |file_line|
          next unless file_line.include?("#{action}_column")

          array = file_line.include?("array: true")
          types = file_line.split(",").map(&:strip)
          types.map { |n| n.gsub!(":", "") }
          types[0].gsub!("#{action}_column ", "")
          unless types[0].to_s == pluralized_class_name
            raise(StandardError, "Wrong class_name!Please Check your migration file!")
          end

          response << { column_name: types[1], type: types[2], array: array }
        end
      end
      response
    end

    def check_schema(class_name: "user")
      schema_data = get_columns_num(class_name: class_name)
      create_migration_data = get_create_migration_type(class_name: class_name)
      add_migration_data = get_migration_type(class_name: class_name, action: "add")
      remove_migration_data = get_migration_type(class_name: class_name, action: "remove")
      migration_data = create_migration_data + add_migration_data - remove_migration_data
      return "Already Up to date!" if schema_data.size == migration_data.size

      schema_data - migration_data
    end
  end
end
