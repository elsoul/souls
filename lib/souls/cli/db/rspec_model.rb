module Souls
  class DB < Thor
    desc "rspec_model [CLASS_NAME]", "Generate Rspec Model Test from schema.rb"
    def rspec_model(class_name)
      file_dir = "./spec/models/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "./spec/models/#{class_name}_spec.rb"
      return "RspecModel already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          RSpec.describe "#{class_name.camelize} Model テスト", type: :model do
            describe "#{class_name.camelize} データを書き込む" do
              it "valid #{class_name.camelize} Model" do
                expect(FactoryBot.build(:#{class_name.singularize})).to be_valid
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
