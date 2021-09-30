module Souls
  class Generate < Thor
    desc "rspec_job [CLASS_NAME]", "Generate Rspec Job Test Template"
    def rspec_job(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./spec/mutations/jobs/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{singularized_class_name}_spec.rb"
      return "RspecJob already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          RSpec.describe("#{class_name.singularize.camelize}") do
            describe "Define #{class_name.singularize.camelize}" do

              let(:mutation) do
                %(mutation {
                  #{class_name.singularize.camelize(:lower)}(input: {}) {
                      response
                    }
                  }
                )
              end

              subject(:result) do
                SoulsApiSchema.execute(mutation).as_json
              end

              it "return StockSheet Data" do
                begin
                  a1 = result.dig("data", "#{options[:mutation].singularize.camelize(:lower)}", "response")
                  raise unless a1.present?
                rescue StandardError
                  raise(StandardError, result)
                end
                expect(a1).to(include("response" => be_a(String)))
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
