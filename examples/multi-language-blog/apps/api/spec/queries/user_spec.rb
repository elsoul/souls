RSpec.describe("User Query テスト") do
  describe "User データを取得する" do
    let!(:user) { FactoryBot.create(:user) }

    let(:query) do
      data_id = Base64.strict_encode64("User:#{user.id}")
      %(query {
          user(id: \"#{data_id}\") {
            id
          uid
          username
          email
          lang
          isDeleted
            }
          }
        )
    end

    subject(:result) do
      SoulsApiSchema.execute(query).as_json
    end

    it "return User Data" do
      begin
        a1 = result.dig("data", "user")
        raise unless a1.present?
      rescue StandardError
        raise(StandardError, result)
      end
      expect(a1).to(
        include(
          "id" => be_a(String),
          "uid" => be_a(String),
          "username" => be_a(String),
          "email" => be_a(String),
          "lang" => be_a(String),
          "isDeleted" => be_in([true, false])
        )
      )
    end
  end
end
