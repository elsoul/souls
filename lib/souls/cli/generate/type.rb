module SOULs
  class Generate < Thor
    desc "type [CLASS_NAME]", "Generate GraphQL Type from schema.rb"
    def type(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./app/graphql/types/#{singularized_class_name}_type.rb"
      return "Type already exist! #{file_path}" if File.exist?(file_path)

      create_type_head(class_name: singularized_class_name)
      create_type_params(class_name: singularized_class_name)
      create_type_end(class_name: singularized_class_name)
      SOULs::Painter.create_file(file_path.to_s)
      file_path
    end

    private

    def create_type_head(class_name: "user")
      file_dir = "./app/graphql/types/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "./app/graphql/types/#{class_name}_type.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Types
            class #{class_name.camelize}Type < SOULs::Types::BaseObject
              implements GraphQL::Types::Relay::Node

        TEXT
      end
    end

    def create_type_params(class_name: "user")
      file_path = "./app/graphql/types/#{class_name}_type.rb"
      path = "./db/schema.rb"
      @on = false
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              new_line.write("\n" && break) if line.include?("t.index") || line.strip == "end"
              field = "[String]" if line.include?("array: true")
              type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
              field ||= SOULs.type_check(type)
              case name
              when /$*_id\z/
                new_line.write(
                  "    field :#{name.gsub(
                    '_id',
                    ''
                  )}, Types::#{name.gsub('_id', '').singularize.camelize}Type, null: false\n"
                )
              else
                new_line.write("    field :#{name}, #{field}, null: true\n")
              end
            end
            if SOULs.table_check(line:, class_name:)
              @on = true
              new_line.write("    global_id_field :id\n")
            end
          end
        end
      end
    end

    def create_type_end(class_name: "user")
      file_path = "./app/graphql/types/#{class_name}_type.rb"
      File.open(file_path, "a") do |f|
        f.write(<<~TEXT)
            end
          end
        TEXT
      end
      file_path
    end
  end
end
