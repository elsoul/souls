module Scaffold
  def self.scaffold_rspec_job_mailer
    <<~QUERYSPECJOB
      RSpec.describe("Mailer") do
        describe "Define Mailer" do

          let(:query) do
            %(query {
              mailer {
                  response
                }
              }
            )
          end

          subject(:result) do
            SoulsApiSchema.execute(query).as_json
          end

          it "return Mailer response" do
            stub_request(:post, "https://api.mailgun.net/v3/YOUR-MAILGUN-DOMAIN/messages")
              .to_return(status: 200, body: "", headers: {})
      #{'      '}
            a1 = result.dig("data", "mailer")
            expect(a1).not_to be_empty
            expect(a1).to(include("response" => be_a(String)))
          end
        end
      end
    QUERYSPECJOB
  end

  def self.scaffold_rspec_job
    <<~QUERYSPECJOB
      RSpec.describe("User") do
        describe "Define User" do

          let(:query) do
            %(query {
              user {
                  response
                }
              }
            )
          end

          subject(:result) do
            SoulsApiSchema.execute(query).as_json
          end

          it "return User response" do
            a1 = result.dig("data", "user")
            expect(a1).not_to be_empty
            expect(a1).to(include("response" => be_a(String)))
          end
        end
      end
    QUERYSPECJOB
  end
end
