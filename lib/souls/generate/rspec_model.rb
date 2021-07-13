module Souls
  module Generate
    class << self
      ## Generate Rspec Model
      def rspec_model class_name: "souls"
        file_path = "./spec/models/#{class_name}_spec.rb"
        return "RspecModel already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            RSpec.describe "#{class_name.camelize} Model テスト", type: :model do
              describe "#{class_name.camelize} データを書き込む" do
                it "valid #{class_name.camelize} Model" do
                  expect(FactoryBot.build(:#{class_name.singularize})).to be_valid
                end
              end
            end
          EOS
        end
        puts "Created file! : #{file_path}"
        file_path
      rescue StandardError => e
        raise StandardError, e
      end
    end
  end
end
