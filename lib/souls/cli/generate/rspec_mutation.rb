module Souls
  class Generate < Thor
    desc "rspec_mutation [CLASS_NAME]", "Generate Rspec Mutation Test from schema.rb"
    def rspec_mutation(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./spec/mutations/base/#{singularized_class_name}_spec.rb"
      return "RspecMutation already exist! #{file_path}" if File.exist?(file_path)

      rspec_mutation_head(class_name: singularized_class_name)
      rspec_mutation_after_head(class_name: singularized_class_name)
      rspec_mutation_params(class_name: singularized_class_name)
      rspec_mutation_params_response(class_name: singularized_class_name)
      rspec_mutation_end(class_name: singularized_class_name)
      Souls::Painter.create_file(file_path.to_s)
      file_path
    rescue StandardError => e
      raise(StandardError, e)
    end

    private

    def rspec_mutation_head(class_name: "user")
      file_dir = "./spec/mutations/base/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "./spec/mutations/base/#{class_name.singularize}_spec.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          RSpec.describe \"#{class_name.camelize} Mutation テスト\" do
            describe "#{class_name.camelize} データを登録する" do
        TEXT
      end
    end

    def rspec_mutation_after_head(class_name: "user")
      file_path = "./spec/mutations/base/#{class_name.singularize}_spec.rb"
      path = "./db/schema.rb"
      @on = false
      @user_exist = false
      @relation_params = []
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              if line.include?("t.index") || line.strip == "end"
                if @relation_params.empty?
                  new_line.write(<<-TEXT)
    let(:#{class_name}) { FactoryBot.attributes_for(:#{class_name}) }

    let(:mutation) do
      %(mutation {
        create#{class_name.camelize}(input: {
                  TEXT
                else
                  new_line.write(<<-TEXT)
    let(:#{class_name}) { FactoryBot.attributes_for(:#{class_name}, #{@relation_params.join(', ')}) }

    let(:mutation) do
      %(mutation {
        create#{class_name.camelize}(input: {
                  TEXT
                end
                break
              end
              _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
              case name
              when "user_id"
                relation_col = name.gsub("_id", "")
                new_line.write("    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n")
              when /$*_id\z/
                relation_col = name.gsub("_id", "")
                @relation_params << "#{name}: get_global_key(\"#{name.singularize.camelize.gsub(
                  'Id',
                  ''
                )}\", #{relation_col}.id)"
                new_line.write("    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n")
              end
            end
            @on = true if Souls.table_check(line:, class_name:)
          end
        end
      end
    end

    def rspec_mutation_params(class_name: "user")
      file_path = "./spec/mutations/base/#{class_name.singularize}_spec.rb"
      path = "./db/schema.rb"
      @on = false
      @user_exist = false
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              if line.include?("t.index") || line.strip == "end"
                new_line.write(
                  "        }) {\n            #{class_name.singularize.camelize(:lower)}Edge {\n          node {\n"
                )
                new_line.write("              id\n")
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
                camel = name.singularize.camelize(:lower)
                new_line.write(
                  "          #{camel}: \"\#{#{class_name.singularize}[:#{name.singularize.underscore}]}\"\n"
                )
              else
                camel = name.singularize.camelize(:lower)
                camels = name.pluralize.camelize(:lower)
                case type
                when "string", "text", "date", "datetime"
                  if array_true
                    new_line.write(
                      "          #{camels}: \#{#{class_name.singularize}[:#{name.pluralize.underscore}]}\n"
                    )
                  else
                    new_line.write(
                      "          #{camel}: \"\#{#{class_name.singularize}[:#{name.singularize.underscore}]}\"\n"
                    )
                  end
                when "bigint", "integer", "float", "boolean"
                  new_line.write(
                    "          #{camel}: \#{#{class_name.singularize}[:#{name.singularize.underscore}]}\n"
                  )
                end
              end
            end
            @on = true if Souls.table_check(line:, class_name:)
          end
        end
      end
    end

    def rspec_mutation_params_response(class_name: "user")
      file_path = "./spec/mutations/base/#{class_name.singularize}_spec.rb"
      path = "./db/schema.rb"
      @on = false
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              if line.include?("t.index") || line.strip == "end"
                if @user_exist
                  new_line.write(<<-TEXT)
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
                  TEXT
                else
                  new_line.write(<<-TEXT)
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
                  TEXT
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
                  new_line.write("              #{name.pluralize.camelize(:lower)}\n")
                else
                  new_line.write("              #{name.singularize.camelize(:lower)}\n")
                end
              end
            end
            @on = true if Souls.table_check(line:, class_name:)
          end
        end
      end
    end

    def rspec_mutation_end(class_name: "user")
      file_path = "./spec/mutations/base/#{class_name.singularize}_spec.rb"
      path = "./db/schema.rb"
      @on = false
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              if line.include?("t.index") || line.strip == "end"
                new_line.write(<<~TEXT)
                          )
                      end
                    end
                  end
                TEXT
                break
              end
              type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
              field ||= Souls.type_check(type)
              array_true = line.include?("array: true")
              case name
              when "user_id", "created_at", "updated_at", /$*_id\z/
                next
              else
                case type
                when "text", "date", "datetime"
                  if array_true
                    new_line.write("        \"#{name.pluralize.camelize(:lower)}\" => be_all(String),\n")
                  else
                    new_line.write("        \"#{name.singularize.camelize(:lower)}\" => be_a(String),\n")
                  end
                when "boolean"
                  if array_true
                    new_line.write("        \"#{name.pluralize.camelize(:lower)}\" => be_all([true, false]),\n")
                  else
                    new_line.write("        \"#{name.singularize.camelize(:lower)}\" => be_in([true, false]),\n")
                  end
                when "string", "bigint", "integer", "float"
                  if array_true
                    new_line.write("        \"#{name.pluralize.camelize(:lower)}\" => be_all(#{field}),\n")
                  else
                    new_line.write("        \"#{name.singularize.camelize(:lower)}\" => be_a(#{field}),\n")
                  end
                end
              end
            end
            @on = true if Souls.table_check(line:, class_name:)
          end
        end
      end
      file_path
    end
  end
end
