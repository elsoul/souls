module Souls
  module Generate
    class << self
      ## Generate 4 Mutations - ["create", "update", "delete", "destroy_delete"]
      ## 1.Mutation - Create
      def create_mutation_head class_name: "user"
        singularized_class_name = class_name.singularize.underscore
        dir_name = "./app/graphql/mutations/#{singularized_class_name}"
        FileUtils.mkdir_p dir_name unless Dir.exist? dir_name
        file_path = "./app/graphql/mutations/#{singularized_class_name}/create_#{singularized_class_name}.rb"
        File.open(file_path, "w") do |new_line|
          new_line.write <<~EOS
            module Mutations
              module #{singularized_class_name.camelize}
                class Create#{singularized_class_name.camelize} < BaseMutation
                  field :#{singularized_class_name}_edge, Types::#{singularized_class_name.camelize}NodeType, null: false
                  field :error, String, null: true

          EOS
        end
        file_path
      end

      def create_mutation_params class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/create_#{class_name}.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @user_exist
                    new_line.write <<-EOS

      def resolve **args
        args[:user_id] = context[:user].id
                    EOS
                  else
                    new_line.write <<-EOS

      def resolve **args
                    EOS
                  end
                  break
                end
                field = "[String]" if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
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
        @relation_params
      end

      def create_mutation_after_params class_name: "article", relation_params: []
        return false if relation_params.empty?
        file_path = "./app/graphql/mutations/#{class_name}/create_#{class_name}.rb"
        relation_params.each do |params_name|
          File.open(file_path, "a") do |new_line|
            new_line.write "        _, args[:#{params_name}] = SoulsApiSchema.from_global_id(args[:#{params_name}])\n"
          end
        end
        true
      end

      def create_mutation_end class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/create_#{class_name}.rb"
        File.open(file_path, "a") do |new_line|
          new_line.write <<~EOS
                    #{class_name} = ::#{class_name.camelize}.new args
                    if #{class_name}.save
                      { #{class_name}_edge: { node: #{class_name} } }
                    else
                      { error: #{class_name}.errors.full_messages }
                    end
                  rescue StandardError => error
                    GraphQL::ExecutionError.new error
                  end
                end
              end
            end
          EOS
        end
        file_path
      end

      ## 2.Mutation - Update
      def update_mutation_head class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        File.open(file_path, "w") do |new_line|
          new_line.write <<~EOS
            module Mutations
              module #{class_name.camelize}
                class Update#{class_name.camelize} < BaseMutation
                  field :#{class_name}_edge, Types::#{class_name.camelize}NodeType, null: false

                  argument :id, String, required: true
          EOS
        end
        file_path
      end

      def update_mutation_params class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @user_exist
                    new_line.write <<-EOS

      def resolve **args
        args[:user_id] = context[:user].id
        _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
                    EOS
                  else
                    new_line.write <<-EOS

      def resolve **args
        _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
                    EOS
                  end
                  break
                end
                field = "[String]" if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
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
        @relation_params
      end

      def update_mutation_after_params class_name: "article", relation_params: []
        return false if relation_params.empty?
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        relation_params.each do |params_name|
          File.open(file_path, "a") do |new_line|
            new_line.write "        _, args[:#{params_name}] = SoulsApiSchema.from_global_id(args[:#{params_name}])\n"
          end
        end
        true
      end

      def update_mutation_end class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        File.open(file_path, "a") do |new_line|
          new_line.write <<~EOS
                    #{class_name} = ::#{class_name.camelize}.find args[:id]
                    #{class_name}.update args
                    { #{class_name}_edge: { node: ::#{class_name.camelize}.find(args[:id]) } }
                  rescue StandardError => error
                    GraphQL::ExecutionError.new error
                  end
                end
              end
            end
          EOS
        end
        file_path
      end

      def update_mutation class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        return "Mutation already exist! #{file_path}" if File.exist? file_path
        update_mutation_head class_name: class_name
        relation_params = update_mutation_params class_name: class_name
        update_mutation_after_params class_name: class_name, relation_params: relation_params
        update_mutation_end class_name: class_name
      end

      # 3. Mutation - Delete
      def delete_mutation class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/delete_#{class_name}.rb"
        return "Mutation already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
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
          EOS
        end
        file_path
      end

      # 4. Mutation - Destroy Delete
      def destroy_delete_mutation class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/destroy_delete_#{class_name}.rb"
        return "Mutation already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
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
          EOS
        end
        file_path
      rescue StandardError => error
        puts error
      end

      def mutation class_name: "souls"
        singularized_class_name = class_name.singularize
        file_path = "./app/graphql/mutations/#{singularized_class_name}/create_#{singularized_class_name}.rb"
        return "Mutation already exist! #{file_path}" if File.exist? file_path
        create_mutation_head class_name: singularized_class_name
        relation_params = create_mutation_params class_name: singularized_class_name
        create_mutation_after_params class_name: singularized_class_name, relation_params: relation_params
        [
          create_mutation_end(class_name: singularized_class_name),
          update_mutation(class_name: singularized_class_name),
          delete_mutation(class_name: singularized_class_name),
          destroy_delete_mutation(class_name: singularized_class_name)
        ]
      rescue StandardError => error
        puts error
      end
    end
  end
end
