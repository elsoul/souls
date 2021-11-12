module OutputScaffold
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
