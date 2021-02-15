module Souls
  module Init
    class << self
      def node_type class_name: "souls"
        file_path = "./app/graphql/types/#{class_name.singularize}_node_type.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Types
              class #{class_name.camelize}NodeType < GraphQL::Schema::Object
                field :node, Types::#{class_name.camelize}Type, null: true
              end
            end
          EOS
        end
        [file_path]
      end

      def resolver class_name: "souls"
        FileUtils.mkdir_p "./app/graphql/resolvers" unless Dir.exist? "./app/graphql/resolvers"
        file_path = "./app/graphql/resolvers/#{class_name.singularize}_search.rb"
        return ["Resolver already exist! #{file_path}"] if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Resolvers
              class #{class_name.camelize}Search < Base
                include SearchObject.module(:graphql)
                scope { ::#{class_name.camelize}.all }
                type Types::#{class_name.camelize}Type.connection_type, null: false
                description "Search #{class_name.camelize}"

                class #{class_name.camelize}Filter < ::Types::BaseInputObject
                  argument :OR, [self], required: false

                  argument :is_deleted, Boolean, required: false
                  argument :start_date, String, required: false
                  argument :end_date, String, required: false
                end

                option :filter, type: #{class_name.camelize}Filter, with: :apply_filter
                option :first, type: types.Int, with: :apply_first
                option :skip, type: types.Int, with: :apply_skip

                def apply_filter(scope, value)
                  branches = normalize_filters(value).inject { |a, b| a.or(b) }
                  scope.merge branches
                end

                def apply_first(scope, value)
                  scope.limit(value)
                end

                def apply_skip(scope, value)
                  scope.offset(value)
                end

                def decode_global_key id
                  _, data_id = SoulsApiSchema.from_global_id id
                  data_id
                end

                def normalize_filters(value, branches = [])
                  scope = ::#{class_name.camelize}.all

                  scope = scope.where(is_deleted: value[:is_deleted]) if value[:is_deleted]
                  scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
                  scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]

                  branches << scope

                  value[:OR].inject(branches) { |s, v| normalize_filters(v, s) } if value[:OR].present?

                  branches
                end
              end
            end
          EOS
        end
        [file_path]
      end

      def job class_name: "send_mail"
        file_path = "./app/jobs/#{class_name.singularize}_job.rb"
        return ["Job already exist! #{file_path}"] if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            class #{class_name.camelize}
              include Sidekiq::Status::Worker
              include Sidekiq::Worker
              sidekiq_options queue: "default"

              def perform **args
                # write task code here
              end
            end
          EOS
        end
        [file_path]
      end

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
    let(:#{class_name}) { FactoryBot.create(:#{class_name}, #{@relation_params.join(", ")}) }

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
                  new_line.write <<-EOS
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
        [file_path]
      end

      def rspec_resolver class_name: "souls"
        singularized_class_name = class_name.singularize
        file_path = "#{Dir.pwd}/spec/resolvers/#{singularized_class_name}_search_spec.rb"
        return ["Resolver already exist! #{file_path}"] if File.exist? file_path
        rspec_resolver_head class_name: singularized_class_name
        rspec_resolver_after_head class_name: singularized_class_name
        rspec_resolver_params class_name: singularized_class_name
        rspec_resolver_end class_name: singularized_class_name
      end
    end
  end
end
