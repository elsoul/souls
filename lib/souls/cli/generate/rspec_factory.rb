module Souls
  class Generate < Thor
    desc "rspec_factory [CLASS_NAME]", "Generate Rspec Factory Test from schema.rb"
    def rspec_factory(class_name)
      file_path = "./spec/factories/#{class_name.pluralize}.rb"
      return "RspecFactory already exist! #{file_path}" if File.exist?(file_path)

      singularized_class_name = class_name.singularize
      rspec_factory_head(class_name: singularized_class_name)
      rspec_factory_params(class_name: singularized_class_name)
      rspec_factory_end(class_name: singularized_class_name)
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    private

    def rspec_factory_head(class_name: "user")
      file_path = "./spec/factories/#{class_name.pluralize}.rb"
      FileUtils.mkdir_p("./spec/factories/") unless Dir.exist?("./spec/factories/")
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          FactoryBot.define do
            factory :#{class_name} do
        TEXT
      end
    end

    def rspec_factory_params(class_name: "user")
      file_path = "./spec/factories/#{class_name.pluralize}.rb"
      path = "./db/schema.rb"
      @on = false
      File.open(file_path, "a") do |new_line|
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, _i|
            if @on
              new_line.write("\n" && break) if line.include?("t.index") || line.strip == "end"
              field = '["tag1", "tag2", "tag3"]' if line.include?("array: true")
              type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
              field ||= Souls.get_test_type(type)
              if type == "bigint" && name.include?("_id")
                id_name = name.gsub("_id", "")
                new_line.write("    association :#{id_name}, factory: :#{id_name}\n")
              else
                new_line.write("    #{name} { #{field} }\n")
              end
            end
            @on = true if Souls.table_check(line: line, class_name: class_name)
          end
        end
      end
    end

    def rspec_factory_end(class_name: "user")
      file_path = "./spec/factories/#{class_name.pluralize}.rb"
      File.open(file_path, "a") do |f|
        f.write(<<~TEXT)
            end
          end
        TEXT
      end
      file_path
    end
  end
end
