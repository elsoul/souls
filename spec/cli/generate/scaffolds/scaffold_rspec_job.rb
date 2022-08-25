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
            SOULsApiSchema.execute(query).as_json
          end

          it "return Mailer response" do
            allow_any_instance_of(::Mailgun::Client).to(receive(:send_message).and_return(true))
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
            SOULsApiSchema.execute(query).as_json
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
