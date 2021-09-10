module Souls
  module Api::Generate
    ## Generate Rspec Resolver
    class << self
      def rspec_resolver_head(class_name: "user")
        file_dir = "./spec/resolvers/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            RSpec.describe \"#{class_name.camelize}Search Resolver テスト\" do
              describe "削除フラグ false の #{class_name.camelize} を返却する" do
          TEXT
        end
      end

      def rspec_resolver_after_head(class_name: "user")
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
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
      let!(:#{class_name}) { FactoryBot.create(:#{class_name}) }

      let(:query) do
        %(query {
          #{class_name.singularize.camelize(:lower)}Search(filter: {
            isDeleted: false
        }) {
            edges {
              cursor
              node {
                id
                    TEXT
                  else
                    new_line.write(<<-TEXT)
      let!(:#{class_name}) { FactoryBot.create(:#{class_name}, #{@relation_params.join(', ')}) }

      let(:query) do
        %(query {
          #{class_name.singularize.camelize(:lower)}Search(filter: {
            isDeleted: false
        }) {
            edges {
              cursor
              node {
                id
                    TEXT
                  end
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when /$*_id\z/
                  relation_col = name.gsub("_id", "")
                  @relation_params << "#{name}: #{relation_col}.id"
                  new_line.write("    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n")
                end
              end
              @on = true if Souls.table_check(line: line, class_name: class_name)
            end
          end
        end
      end

      def rspec_resolver_params(class_name: "user")
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, _i|
              if @on
                if line.include?("t.index") || line.strip == "end"
                  new_line.write(<<-TEXT)
                }
              }
              nodes {
                id
              }
              pageInfo {
                endCursor
                hasNextPage
                startCursor
                hasPreviousPage
              }
            }
          }
        )
      end

      subject(:result) do
        SoulsApiSchema.execute(query).as_json
      end

      it "return #{class_name.camelize} Data" do
        begin
          a1 = result.dig("data", "#{class_name.singularize.camelize(:lower)}Search", "edges")[0]["node"]
          raise unless a1.present?
        rescue
          raise StandardError, result
        end
        expect(a1).to include(
          "id" => be_a(String),
                  TEXT
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  new_line.write("              #{name.camelize(:lower)}\n")
                end
              end
              @on = true if Souls.table_check(line: line, class_name: class_name)
            end
          end
        end
      end

      def rspec_resolver_end(class_name: "user")
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
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
                      new_line.write("        \"#{name.camelize(:lower)}\" => be_all(String),\n")
                    else
                      new_line.write("        \"#{name.camelize(:lower)}\" => be_a(String),\n")
                    end
                  when "boolean"
                    if array_true
                      new_line.write("        \"#{name.camelize(:lower)}\" => be_all([true, false]),\n")
                    else
                      new_line.write("        \"#{name.singularize.camelize(:lower)}\" => be_in([true, false]),\n")
                    end
                  when "string", "bigint", "integer", "float"
                    if array_true
                      new_line.write("        \"#{name.camelize(:lower)}\" => be_all(#{field}),\n")
                    else
                      new_line.write("        \"#{name.singularize.camelize(:lower)}\" => be_a(#{field}),\n")
                    end
                  end
                end
              end
              @on = true if Souls.table_check(line: line, class_name: class_name)
            end
          end
        end
        file_path
      end

      def rspec_resolver(class_name: "user")
        singularized_class_name = class_name.singularize
        file_path = "./spec/resolvers/#{singularized_class_name}_search_spec.rb"
        return "Resolver already exist! #{file_path}" if File.exist?(file_path)

        rspec_resolver_head(class_name: singularized_class_name)
        rspec_resolver_after_head(class_name: singularized_class_name)
        rspec_resolver_params(class_name: singularized_class_name)
        rspec_resolver_end(class_name: singularized_class_name)
        puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        file_path
      rescue StandardError => e
        raise(StandardError, e)
      end
    end
  end
end
