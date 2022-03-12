module SOULs
  class Generate < Thor
    desc "mutation_rbs [CLASS_NAME]", "Generate GraphQL Mutation RBS from schema.rb"
    def mutation_rbs(class_name)
      singularized_class_name = class_name.underscore.singularize
      create_rbs_mutation(class_name: singularized_class_name)
      update_rbs_mutation(class_name: singularized_class_name)
      delete_rbs_mutation(class_name: singularized_class_name)
      destroy_delete_rbs_mutation(class_name: singularized_class_name)
    end

    private

    def create_rbs_mutation(class_name: "user")
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/base/#{class_name}"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/create_#{class_name}.rbs"
        raise(Thor::Error, "Mutation RBS already exist! #{file_path}") if File.exist?(file_path)

        params = SOULs.get_relation_params(class_name:, col: "mutation")
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            class Boolean
            end
            module Mutations
              module Base
                module #{class_name.camelize}
                  class Create#{class_name.camelize} < BaseMutation
                    String: String
                    Boolean: Boolean
                    Integer: Integer
                    def resolve:  ({
          TEXT
        end
        File.open(file_path, "a") do |f|
          params[:params].each_with_index do |param, i|
            type = SOULs.rbs_type_check(param[:type])
            type = "[#{type}]" if param[:array]
            if i == params[:params].size - 1
              f.write("                          #{param[:column_name]}: #{type}?\n")
            elsif param[:column_name].match?(/$*_id\z/)
              f.write("                          #{param[:column_name]}: String?,\n")
            else
              f.write("                          #{param[:column_name]}: #{type}?,\n")
            end
          end
        end
        # rubocop:disable Layout/LineLength
        File.open(file_path, "a") do |f|
          f.write("                      }) -> ({ :#{class_name}_edge => { :node => String } } | ::GraphQL::ExecutionError )\n\n")
        end
        # rubocop:enable Layout/LineLength

        File.open(file_path, "a") do |f|
          params[:params].each_with_index do |param, i|
            type = SOULs.type_check(param[:type])
            rbs_type = SOULs.rbs_type_check(param[:type])
            type = "[#{type}]" if param[:array]
            if i.zero?
              if param[:column_name].match?(/$*_id\z/)
                f.write(
                  "        def self.argument: (:#{param[:column_name]}, String, " \
                                    "required: false ) -> #{rbs_type}\n"
                )
              else
                f.write(
                  "        def self.argument: (:#{param[:column_name]}, #{type}, " \
                                    "required: false ) -> #{rbs_type}\n"
                )
              end
            elsif param[:column_name].match?(/$*_id\z/)
              f.write("                         | (:#{param[:column_name]}, String, required: false ) -> String\n")
            else
              f.write(
                "                         | (:#{param[:column_name]}, #{type}, " \
                                "required: false ) -> #{rbs_type}\n"
              )
            end
          end
        end

        File.open(file_path, "a") do |f|
          f.write(<<~TEXT)

                    def self.field: (*untyped) -> String
                    attr_accessor context: {user:{
                      id: Integer,
                      username: String,
                      email: String
                    }}
                  end
                end
              end
            end
          TEXT
        end
      end
      SOULs::Painter.create_file(file_path.to_s)
      file_path
    end

    def update_rbs_mutation(class_name: "user")
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/base/#{class_name}"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/update_#{class_name}.rbs"
        params = SOULs.get_relation_params(class_name:, col: "mutation")
        params[:params] << { column_name: "id", type: "string", array: false }
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Mutations
              module Base
                module #{class_name.camelize}
                  class Update#{class_name.camelize} < BaseMutation
                    String: String
                    Boolean: Boolean
                    Integer: Integer
                    def resolve:  ({
                                    id: String,
          TEXT
        end
        File.open(file_path, "a") do |f|
          cols = params[:params].reject { |n| n[:column_name] == "user_id" }
          cols.each_with_index do |param, i|
            type = SOULs.rbs_type_check(param[:type])
            type = "[#{type}]" if param[:array]
            type = "String" if param[:column_name].match?(/$*_id\z/)

            if i == params[:params].size - 1
              f.write("                          #{param[:column_name]}: #{type}?\n")
            else
              f.write("                          #{param[:column_name]}: #{type}?,\n")
            end
          end
        end
        # rubocop:disable Layout/LineLength
        File.open(file_path, "a") do |f|
          f.write("                      }) -> ({ :#{class_name}_edge => { :node => String } } | ::GraphQL::ExecutionError )\n\n")
        end
        # rubocop:enable Layout/LineLength

        File.open(file_path, "a") do |f|
          cols = params[:params].reject { |n| n[:column_name] == "user_id" }
          cols.each_with_index do |param, i|
            type = SOULs.type_check(param[:type])
            rbs_type = SOULs.rbs_type_check(param[:type])
            type = "[#{type}]" if param[:array]
            type = "String" if param[:column_name].match?(/$*_id\z/)
            rbs_type = "String" if param[:column_name].match?(/$*_id\z/)

            required = param[:column_name] == "id" ? "required: true" : "required: false"
            if i.zero?
              f.write("        def self.argument: (:#{param[:column_name]}, #{type}, #{required} ) -> #{rbs_type}\n")
            else
              f.write("                         | (:#{param[:column_name]}, #{type}, #{required} ) -> #{rbs_type}\n")
            end
          end
        end

        File.open(file_path, "a") do |f|
          f.write(<<~TEXT)

                    def self.field: (*untyped) -> String
                    attr_accessor context: {user:{
                      id: Integer,
                      username: String,
                      email: String
                    }}
                  end
                end
              end
            end
          TEXT
        end
      end
      SOULs::Painter.create_file(file_path.to_s)
      file_path
    end

    def delete_rbs_mutation(class_name: "user")
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/base/#{class_name}"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/delete_#{class_name}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Mutations
              module Base
                module #{class_name.camelize}
                  class Delete#{class_name.camelize}
                    def resolve:  ({
                                      id: String
                                   }) -> ( Hash[Symbol, untyped] | ::GraphQL::ExecutionError )
            #{'        '}
                    def self.argument: (*untyped) -> String
                    def self.field: (*untyped) -> String
                  end
                end
              end
            end
          TEXT
        end
        SOULs::Painter.create_file(file_path.to_s)
      end
      file_path
    end

    def destroy_delete_rbs_mutation(class_name: "user")
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/base/#{class_name}"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/destroy_delete_#{class_name}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Mutations
              module Base
                module #{class_name.camelize}
                  class DestroyDelete#{class_name.camelize}
                    def resolve:  ({
                                      id: String
                                   }) -> ( Hash[Symbol, untyped] | ::GraphQL::ExecutionError )
            #{'        '}
                    def self.argument: (*untyped) -> String
                    def self.field: (*untyped) -> String
                  end
                end
              end
            end
          TEXT
        end
        SOULs::Painter.create_file(file_path.to_s)
      end
      file_path
    end
  end
end
