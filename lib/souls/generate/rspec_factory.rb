module Souls
  module Generate
    class << self
      ## Generate Rspec Factory
      def rspec_factory_head class_name: "souls"
        file_path = "./spec/factories/#{class_name.pluralize}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            FactoryBot.define do
              factory :#{class_name} do
          EOS
        end
      end

      def rspec_factory_params class_name: "souls"
        file_path = "./spec/factories/#{class_name.pluralize}.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                new_line.write "\n" && break if line.include?("end") || line.include?("t.index")
                field = '["tag1", "tag2", "tag3"]' if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= get_test_type type
                if type == "bigint" && name.include?("_id")
                  id_name = name.gsub("_id", "")
                  new_line.write "    association :#{id_name}, factory: :#{id_name}\n"
                else
                  new_line.write "    #{name} { #{field} }\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_factory_end class_name: "souls"
        file_path = "./spec/factories/#{class_name.pluralize}.rb"
        File.open(file_path, "a") do |f|
          f.write <<~EOS
              end
            end
          EOS
        end
        file_path
      end

      def rspec_factory class_name: "souls"
        file_path = "./spec/factories/#{class_name.pluralize}.rb"
        return "RspecFactory already exist! #{file_path}" if File.exist? file_path
        singularized_class_name = class_name.singularize
        rspec_factory_head class_name: singularized_class_name
        rspec_factory_params class_name: singularized_class_name
        rspec_factory_end class_name: singularized_class_name
      end
    end
  end
end
