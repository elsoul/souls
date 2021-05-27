module Souls
  module Generate
    class << self
      ## Generate  Rspec Mutation
      def rspec_mutation_head class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        return "RspecMutation already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            RSpec.describe \"#{class_name.camelize} Mutation テスト\" do
              describe "#{class_name.camelize} データを登録する" do
          EOS
        end
      end

      def rspec_mutation_after_head class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @relation_params.empty?
                    new_line.write <<-EOS
    let(:#{class_name}) { FactoryBot.attributes_for(:#{class_name}) }

    let(:mutation) do
      %(mutation {
        create#{class_name.camelize}(input: {
                    EOS
                  else
                    new_line.write <<-EOS
    let(:#{class_name}) { FactoryBot.attributes_for(:#{class_name}, #{@relation_params.join(", ")}) }

    let(:mutation) do
      %(mutation {
        create#{class_name.camelize}(input: {
                    EOS
                  end
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when "user_id"
                  relation_col = name.gsub("_id", "")
                  new_line.write "    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n"
                when /$*_id\z/
                  relation_col = name.gsub("_id", "")
                  @relation_params << "#{name}: get_global_key(\"#{name.singularize.camelize.gsub("Id", "")}\", #{relation_col}.id)"
                  new_line.write "    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_mutation_params class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  new_line.write "        }) {\n            #{class_name.singularize.camelize(:lower)}Edge {\n          node {\n"
                  new_line.write "              id\n"
                  break
                end
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                array_true = line.include?("array: true")
                case name
                when "created_at", "updated_at"
                  next
                when "user_id"
                  @user_exist = true
                when /$*_id\z/
                  new_line.write "          #{name.singularize.camelize(:lower)}: \"\#{#{class_name.singularize}[:#{name.singularize.underscore}]}\"\n"
                else
                  case type
                  when "string", "text", "date", "datetime"
                    if array_true
                      new_line.write "          #{name.pluralize.camelize(:lower)}: \#{#{class_name.singularize}[:#{name.pluralize.underscore}]}\n"
                    else
                      new_line.write "          #{name.singularize.camelize(:lower)}: \"\#{#{class_name.singularize}[:#{name.singularize.underscore}]}\"\n"
                    end
                  when "bigint", "integer", "float", "boolean"
                    new_line.write "          #{name.singularize.camelize(:lower)}: \#{#{class_name.singularize}[:#{name.singularize.underscore}]}\n"
                  end
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_mutation_params_response class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @user_exist
                    new_line.write <<-EOS
              }
            }
          }
        }
      )
    end

    subject(:result) do
      context = {
        user: user
      }
      SoulsApiSchema.execute(mutation, context: context).as_json
    end

    it "return #{class_name.camelize} Data" do
      begin
        a1 = result.dig("data", "create#{class_name.singularize.camelize}", "#{class_name.singularize.camelize(:lower)}Edge", "node")
        raise unless a1.present?
      rescue
        raise StandardError, result
      end
      expect(a1).to include(
        "id" => be_a(String),
                    EOS
                  else
                    new_line.write <<-EOS
              }
            }
          }
        }
      )
    end

    subject(:result) do
      SoulsApiSchema.execute(mutation).as_json
    end

    it "return #{class_name.camelize} Data" do
      begin
        a1 = result.dig("data", "create#{class_name.singularize.camelize}", "#{class_name.singularize.camelize(:lower)}Edge", "node")
        raise unless a1.present?
      rescue
        raise StandardError, result
      end
      expect(a1).to include(
        "id" => be_a(String),
                    EOS
                  end
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                array_true = line.include?("array: true")
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  if array_true
                    new_line.write "              #{name.pluralize.camelize(:lower)}\n"
                  else
                    new_line.write "              #{name.singularize.camelize(:lower)}\n"
                  end
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_mutation_end class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  new_line.write <<~EOS
                            )
                        end
                      end
                    end
                  EOS
                  break
                end
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= type_check type
                array_true = line.include?("array: true")
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  case type
                  when "text", "date", "datetime"
                      if array_true
                        new_line.write "        \"#{name.pluralize.camelize(:lower)}\" => be_all(String),\n"
                      else
                        new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_a(String),\n"
                      end
                  when "boolean"
                    new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_in([true, false]),\n"
                  when "string", "bigint", "integer", "float"
                    new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_a(#{field}),\n"
                  end
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
        file_path
      end

      def rspec_mutation class_name: "souls"
        singularized_class_name = class_name.singularize
        rspec_mutation_head class_name: singularized_class_name
        rspec_mutation_after_head class_name: singularized_class_name
        rspec_mutation_params class_name: singularized_class_name
        rspec_mutation_params_response class_name: singularized_class_name
        rspec_mutation_end class_name: singularized_class_name
      end
    end
  end
end
