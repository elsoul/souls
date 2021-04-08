module Souls
  module Generate
    class << self
      ## Generate Rspec Resolver
      def rspec_resolver_head class_name: "souls"
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            RSpec.describe \"#{class_name.camelize}Search Resolver テスト\" do
              describe "削除フラグ false の #{class_name.camelize} を返却する" do
          EOS
        end
      end

      def rspec_resolver_after_head class_name: "souls"
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
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
                    EOS
                  else
                    new_line.write <<-EOS
    let!(:#{class_name}) { FactoryBot.create(:#{class_name}, #{@relation_params.join(", ")}) }

    let(:query) do
      %(query {
        #{class_name.singularize.camelize(:lower)}Search(filter: {
          isDeleted: false
      }) {
          edges {
            cursor
            node {
              id
                    EOS
                  end
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when /$*_id\z/
                  relation_col = name.gsub("_id", "")
                  @relation_params << "#{name}: #{relation_col}.id"
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

      def rspec_resolver_params class_name: "souls"
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  new_line.write <<-EOS
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
                  EOS
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  new_line.write "              #{name.camelize(:lower)}\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_resolver_end class_name: "souls"
        file_path = "./spec/resolvers/#{class_name.singularize}_search_spec.rb"
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
                        new_line.write "        \"#{name.camelize(:lower)}\" => be_all(String),\n"
                      else
                        new_line.write "        \"#{name.camelize(:lower)}\" => be_a(String),\n"
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

      def rspec_resolver class_name: "souls"
        singularized_class_name = class_name.singularize
        file_path = "#{Dir.pwd}/spec/resolvers/#{singularized_class_name}_search_spec.rb"
        return "Resolver already exist! #{file_path}" if File.exist? file_path
        rspec_resolver_head class_name: singularized_class_name
        rspec_resolver_after_head class_name: singularized_class_name
        rspec_resolver_params class_name: singularized_class_name
        rspec_resolver_end class_name: singularized_class_name
      end
    end
  end
end
