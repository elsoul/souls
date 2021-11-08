module Souls
  class Generate < Thor
    desc "mutation [CLASS_NAME]", "Generate GraphQL Mutation from schema.rb"
    def mutation(class_name)
      singularized_class_name = class_name.singularize

      Dir.chdir(Souls.get_api_path.to_s) do
        file_dir = "./app/graphql/mutations/base"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "./app/graphql/mutations/base/#{singularized_class_name}/create_#{singularized_class_name}.rb"
        return "Mutation already exist! #{file_path}" if File.exist?(file_path)

        create_mutation(singularized_class_name)
        update_mutation(singularized_class_name)
        delete_mutation(singularized_class_name)
        destroy_delete_mutation(singularized_class_name)
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def create_mutation(class_name)
      singularized_class_name = class_name.singularize.underscore
      file_dir = "./app/graphql/mutations/base/#{singularized_class_name}"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/create_#{singularized_class_name}.rb"
      raise(Thor::Error, "Mutation RBS already exist! #{file_path}") if File.exist?(file_path)

      params = Souls.get_relation_params(class_name: singularized_class_name, col: "mutation")
      File.open(file_path, "a") do |f|
        f.write(<<~TEXT)
          module Mutations
            module Base::#{singularized_class_name.camelize}
              class Create#{singularized_class_name.camelize} < BaseMutation
                field :#{singularized_class_name}_edge, Types::#{singularized_class_name.camelize}Type.edge_type, null: false
                field :error, String, null: true

        TEXT
      end

      File.open(file_path, "a") do |f|
        params[:params].each_with_index do |param, i|
          type = Souls.type_check(param[:type])
          type = "[#{type}]" if param[:array]
          type = "String" if param[:column_name].match?(/$*_id\z/)
          next if param[:column_name] == "user_id"

          if i == params[:params].size - 1
            f.write("      argument :#{param[:column_name]}, #{type}, required: false\n\n")
            f.write("      def resolve(args)\n")
          else
            f.write("      argument :#{param[:column_name]}, #{type}, required: false\n")
          end
        end
      end

      File.open(file_path, "a") do |f|
        if params[:relation_params]
          f.write("        user_id = context[:user][:id]\n") if params[:user_exist]
          params[:relation_params].each_with_index do |col, _i|
            next if col[:column_name] == "user_id"

            f.write("      _, #{col[:column_name]} = SoulsApiSchema.from_global_id(args[:#{col[:column_name]}])\n")
          end
          relation_params =
            params[:relation_params].map do |n|
              ", #{n[:column_name]}: #{n[:column_name]}"
            end
          f.write("        new_record = { **args #{relation_params.compact.join} }\n")
          f.write("        data = ::#{singularized_class_name.camelize}.new(new_record)\n")
        else
          f.write("        data = ::#{singularized_class_name.camelize}.new(args)\n")
        end
      end
      File.open(file_path, "a") do |new_line|
        new_line.write(<<~TEXT)
                  raise(StandardError, data.errors.full_messages) unless data.save

                  { #{singularized_class_name}_edge: { node: data } }
                rescue StandardError => error
                  GraphQL::ExecutionError.new(error.message)
                end
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    def update_mutation(class_name)
      singularized_class_name = class_name.singularize.underscore
      file_dir = "./app/graphql/mutations/base/#{singularized_class_name}"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/update_#{singularized_class_name}.rb"
      raise(Thor::Error, "Mutation RBS already exist! #{file_path}") if File.exist?(file_path)

      params = Souls.get_relation_params(class_name: singularized_class_name, col: "mutation")
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            module Base::#{singularized_class_name.camelize}
              class Update#{singularized_class_name.camelize} < BaseMutation
                field :#{singularized_class_name}_edge, Types::#{singularized_class_name.camelize}Type.edge_type, null: false
                field :error, String, null: true

                argument :id, String, required: true
        TEXT
      end

      File.open(file_path, "a") do |f|
        params[:params].each_with_index do |param, i|
          type = Souls.type_check(param[:type])
          type = "[#{type}]" if param[:array]
          type = "String" if param[:column_name].match?(/$*_id\z/)
          next if param[:column_name] == "user_id"

          if i == params[:params].size - 1
            f.write("      argument :#{param[:column_name]}, #{type}, required: false\n\n")
            f.write("      def resolve(args)\n")
            f.write("      _, data_id = SoulsApiSchema.from_global_id(args[:id])\n")
          else
            f.write("      argument :#{param[:column_name]}, #{type}, required: false\n")
          end
        end
      end

      File.open(file_path, "a") do |f|
        if params[:relation_params]
          f.write("        user_id = context[:user][:id]\n") if params[:user_exist]
          params[:relation_params].each_with_index do |col, _i|
            next if col[:column_name] == "user_id"

            f.write("      _, #{col[:column_name]} = SoulsApiSchema.from_global_id(args[:#{col[:column_name]}])\n")
          end
          relation_params =
            params[:relation_params].map do |n|
              ", #{n[:column_name]}: #{n[:column_name]}"
            end
          f.write("        new_record = { **args #{relation_params.compact.join} }\n")
        else
          f.write("        new_record = args.except(:id)\n")
        end
        f.write("        data = ::#{singularized_class_name.camelize}.find(data_id)\n")
        f.write("        data.update(new_record)\n")
      end
      File.open(file_path, "a") do |new_line|
        new_line.write(<<~TEXT)
                  raise(StandardError, data.errors.full_messages) unless data.save

                  { #{singularized_class_name}_edge: { node: data } }
                rescue StandardError => error
                  GraphQL::ExecutionError.new(error.message)
                end
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    # 3. Mutation - Delete
    def delete_mutation(class_name)
      file_path = "./app/graphql/mutations/base/#{class_name}/delete_#{class_name}.rb"
      return "Mutation already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            module Base::#{class_name.camelize}
              class Delete#{class_name.camelize} < BaseMutation
                field :#{class_name}, Types::#{class_name.camelize}Type, null: false
                argument :id, String, required: true

                def resolve args
                  _, data_id = SoulsApiSchema.from_global_id args[:id]
                  #{class_name} = ::#{class_name.camelize}.find data_id
                  #{class_name}.update(is_deleted: true)
                  { #{class_name}: ::#{class_name.camelize}.find(data_id) }
                rescue StandardError => error
                  GraphQL::ExecutionError.new(error.message)
                end
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    # 4. Mutation - Destroy Delete
    def destroy_delete_mutation(class_name)
      file_path = "./app/graphql/mutations/base/#{class_name}/destroy_delete_#{class_name}.rb"
      return "Mutation already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            module Base::#{class_name.camelize}
              class DestroyDelete#{class_name.camelize} < BaseMutation
                field :#{class_name}, Types::#{class_name.camelize}Type, null: false
                argument :id, String, required: true

                def resolve args
                  _, data_id = SoulsApiSchema.from_global_id args[:id]
                  #{class_name} = ::#{class_name.camelize}.find data_id
                  #{class_name}.destroy
                  { #{class_name}: #{class_name} }
                rescue StandardError => error
                  GraphQL::ExecutionError.new(error.message)
                end
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue StandardError => e
      puts(e)
    end
  end
end
