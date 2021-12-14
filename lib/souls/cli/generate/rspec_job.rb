module Souls
  class Generate < Thor
    desc "rspec_job [CLASS_NAME]", "Generate Rspec Job Test Template"
    method_option :mailer, type: :boolean, aliases: "--mailer", default: false, desc: "Mailgun Template"
    def rspec_job(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./spec/queries/jobs/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{singularized_class_name}_spec.rb"
      return "RspecJob already exist! #{file_path}" if File.exist?(file_path)

      if options[:mailer]
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            RSpec.describe("#{singularized_class_name.camelize}") do
              describe "Define #{singularized_class_name.camelize}" do

                let(:query) do
                  %(query {
                    #{singularized_class_name.camelize(:lower)} {
                        response
                      }
                    }
                  )
                end

                subject(:result) do
                  SoulsApiSchema.execute(query).as_json
                end

                it "return #{singularized_class_name.camelize} response" do
                  stub_request(:post, "https://api.mailgun.net/v3/YOUR-MAILGUN-DOMAIN/messages")
                    .to_return(status: 200, body: "", headers: {})
            #{'      '}
                  a1 = result.dig("data", "#{singularized_class_name.camelize(:lower)}")
                  expect(a1).not_to be_empty
                  expect(a1).to(include("response" => be_a(String)))
                end
              end
            end
          TEXT
        end
      else
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            RSpec.describe("#{singularized_class_name.camelize}") do
              describe "Define #{singularized_class_name.camelize}" do

                let(:query) do
                  %(query {
                    #{singularized_class_name.camelize(:lower)} {
                        response
                      }
                    }
                  )
                end

                subject(:result) do
                  SoulsApiSchema.execute(query).as_json
                end

                it "return #{singularized_class_name.camelize} response" do
                  a1 = result.dig("data", "#{singularized_class_name.camelize(:lower)}")
                  expect(a1).not_to be_empty
                  expect(a1).to(include("response" => be_a(String)))
                end
              end
            end
          TEXT
        end
      end
      Souls::Painter.create_file(file_path.to_s)
      file_path
    end
  end
end
