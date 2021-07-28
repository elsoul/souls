module Souls
  module Generate
    ## Generate 4 Mutations - ["create", "update", "delete", "destroy_delete"]
    ## 1.Mutation - Create
    def self.create_mutation_head(class_name: "user")
      singularized_class_name = class_name.singularize.underscore
      dir_name = "./app/graphql/mutations/base/#{singularized_class_name}"
      FileUtils.mkdir_p(dir_name) unless Dir.exist?(dir_name)
      file_path = "./app/graphql/mutations/base/#{singularized_class_name}/create_#{singularized_class_name}.rb"
      File.open(file_path, "w") do |new_line|
        new_line.write(<<~TEXT)
          module Mutations
            module #{singularized_class_name.camelize}
              class Create#{singularized_class_name.camelize} < BaseMutation
                field :#{singularized_class_name}_edge, Types::#{singularized_class_name.camelize}.edge_type, null: false
                field :error, String, null: true

        TEXT
      end
      file_path
    end

    def self.create_mutation_params(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/create_#{class_name}.rb"
      path = "./db/schema.rb"
      @on = false
      @user_exist = false
      @relation_params = []
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              if line.include?("end") || line.include?("t.index")
                if @user_exist
                  new_line.write(<<-TEXT)

    def resolve **args
      args[:user_id] = context[:user].id
                  TEXT
                else
                  new_line.write(<<-TEXT)

    def resolve **args
                  TEXT
                end
                break
              end
              field = "[String]" if line.include?("array: true")
              type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
              field ||= type_check(type)
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
            @on = true if table_check(line: line, class_name: class_name)
          end
        end
      end
      @relation_params
    end

    def self.create_mutation_after_params(class_name: "article", relation_params: [])
      return false if relation_params.empty?

      file_path = "./app/graphql/mutations/base/#{class_name}/create_#{class_name}.rb"
      relation_params.each do |params_name|
        File.open(file_path, "a") do |new_line|
          new_line.write("        _, args[:#{params_name}] = SoulsApiSchema.from_global_id(args[:#{params_name}])\n")
        end
      end
      true
    end

    def self.create_mutation_end(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/create_#{class_name}.rb"
      File.open(file_path, "a") do |new_line|
        new_line.write(<<~TEXT)
                  data = ::#{class_name.camelize}.new args
                  raise(StandardError, data.errors.full_messages) unless data.save

                  { #{class_name}_edge: { node: data } }
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          end
        TEXT
      end
      file_path
    end

    ## 2.Mutation - Update
    def self.update_mutation_head(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name}.rb"
      File.open(file_path, "w") do |new_line|
        new_line.write(<<~TEXT)
          module Mutations
            module #{class_name.camelize}
              class Update#{class_name.camelize} < BaseMutation
                field :#{class_name}_edge, Types::#{class_name.camelize}.edge_type, null: false

                argument :id, String, required: true
        TEXT
      end
      file_path
    end

    def self.update_mutation_params(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name}.rb"
      path = "./db/schema.rb"
      @on = false
      @user_exist = false
      @relation_params = []
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              if line.include?("end") || line.include?("t.index")
                if @user_exist
                  new_line.write(<<-TEXT)

    def resolve **args
      args[:user_id] = context[:user].id
      _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
                  TEXT
                else
                  new_line.write(<<-TEXT)

    def resolve **args
      _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
                  TEXT
                end
                break
              end
              field = "[String]" if line.include?("array: true")
              type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
              field ||= type_check(type)
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
            @on = true if table_check(line: line, class_name: class_name)
          end
        end
      end
      @relation_params
    end

    def self.update_mutation_after_params(class_name: "article", relation_params: [])
      return false if relation_params.empty?

      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name}.rb"
      relation_params.each do |params_name|
        File.open(file_path, "a") do |new_line|
          new_line.write("        _, args[:#{params_name}] = SoulsApiSchema.from_global_id(args[:#{params_name}])\n")
        end
      end
      true
    end

    def self.update_mutation_end(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name}.rb"
      File.open(file_path, "a") do |new_line|
        new_line.write(<<~TEXT)
                  #{class_name} = ::#{class_name.camelize}.find args[:id]
                  #{class_name}.update args
                  { #{class_name}_edge: { node: ::#{class_name.camelize}.find(args[:id]) } }
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          end
        TEXT
      end
      file_path
    end

    def self.update_mutation(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name}.rb"
      return "Mutation already exist! #{file_path}" if File.exist?(file_path)

      update_mutation_head(class_name: class_name)
      relation_params = update_mutation_params(class_name: class_name)
      update_mutation_after_params(class_name: class_name, relation_params: relation_params)
      update_mutation_end(class_name: class_name)
    end

    # 3. Mutation - Delete
    def self.delete_mutation(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/delete_#{class_name}.rb"
      return "Mutation already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            module #{class_name.camelize}
              class Delete#{class_name.camelize} < BaseMutation
                field :#{class_name}, Types::#{class_name.camelize}Type, null: false
                argument :id, String, required: true

                def resolve **args
                  _, data_id = SoulsApiSchema.from_global_id args[:id]
                  #{class_name} = ::#{class_name.camelize}.find data_id
                  #{class_name}.update(is_deleted: true)
                  { #{class_name}: ::#{class_name.camelize}.find(data_id) }
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          end
        TEXT
      end
      file_path
    end

    # 4. Mutation - Destroy Delete
    def self.destroy_delete_mutation(class_name: "souls")
      file_path = "./app/graphql/mutations/base/#{class_name}/destroy_delete_#{class_name}.rb"
      return "Mutation already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            module #{class_name.camelize}
              class DestroyDelete#{class_name.camelize} < BaseMutation
                field :#{class_name}, Types::#{class_name.camelize}Type, null: false
                argument :id, String, required: true

                def resolve **args
                  _, data_id = SoulsApiSchema.from_global_id args[:id]
                  #{class_name} = ::#{class_name.camelize}.find data_id
                  #{class_name}.destroy
                  { #{class_name}: #{class_name} }
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          end
        TEXT
      end
      file_path
    rescue StandardError => e
      puts(e)
    end

    def self.mutation(class_name: "souls")
      singularized_class_name = class_name.singularize
      file_dir = "./app/graphql/mutations/base"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "./app/graphql/mutations/base/#{singularized_class_name}/create_#{singularized_class_name}.rb"
      return "Mutation already exist! #{file_path}" if File.exist?(file_path)

      create_mutation_head(class_name: singularized_class_name)
      relation_params = create_mutation_params(class_name: singularized_class_name)
      create_mutation_after_params(class_name: singularized_class_name, relation_params: relation_params)
      create_mutation_end(class_name: singularized_class_name)
      update_mutation(class_name: singularized_class_name)
      delete_mutation(class_name: singularized_class_name)
      destroy_delete_mutation(class_name: singularized_class_name)
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue StandardError => e
      raise(StandardError, e)
    end
  end
end
