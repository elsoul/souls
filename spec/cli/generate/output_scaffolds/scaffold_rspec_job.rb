module OutputScaffold
  def self.scaffold_rspec_job
    <<~MUTATIONSPECJOB
RSpec.describe("User") do
  describe "Define User" do

    let(:mutation) do
      %(mutation {
        user(input: {}) {
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
        a1 = result.dig("data", "user")
        raise unless a1.present?
      rescue StandardError
        raise(StandardError, result)
      end
      expect(a1).to(include("response" => be_a(String)))
    end
  end
end
    MUTATIONSPECJOB
  end
end
