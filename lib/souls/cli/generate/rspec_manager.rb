module SOULs
  class Generate < Thor
    desc "rspec_manager [CLASS_NAME]", "Generate Rspec Manager Test Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def rspec_manager(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./spec/managers/#{singularized_class_name}_manager"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{options[:mutation]}_spec.rb"
      return "RspecManager already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          RSpec.describe("#{options[:mutation].singularize.camelize}") do
            describe "Define #{options[:mutation].singularize.camelize}" do

              let(:mutation) do
                %(mutation {
                  #{options[:mutation].singularize.camelize(:lower)}(input: {
                    argument: "argument test!"
                  }) {
                      response
                    }
                  }
                )
              end

              subject(:result) do
                SOULsApiSchema.execute(mutation).as_json
              end

              it "return User response" do
                begin
                  a1 = result.dig("data", "#{options[:mutation].singularize.camelize(:lower)}", "response")
                  raise unless a1.present?
                rescue StandardError
                  raise(StandardError, result)
                end
                expect(a1).to(eq("success!"))
              end
            end
          end
        TEXT
      end
      SOULs::Painter.create_file(file_path.to_s)
      file_path
    end
  end
end
