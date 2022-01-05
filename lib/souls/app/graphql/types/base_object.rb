module SOULs
  module Types
    class BaseObject < GraphQL::Schema::Object
      field_class SOULs::Types::BaseField
      connection_type_class SOULs::SOULsConnection

      def self.get_tables
        path = "./db/schema.rb"
        tables = []
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            tables << line.split("\"")[1] if line.include?("create_table")
          end
        end
        tables
      end
    end
  end
end
