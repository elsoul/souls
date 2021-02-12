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
                  scope = ::Article.all

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

    end
  end
end