RSpec.describe("User Query テスト") do
  describe "User データを取得する" do
    let!(:user) { FactoryBot.create(:user) }

    let(:query) do
      data_id = Base64.encode64("User:#{user.id}")
      %(query {
        user(id: \"#{data_id}\") {
          id
          uid
          username
          screenName
          lastName
          firstName
          lastNameKanji
          firstNameKanji
          lastNameKana
          firstNameKana
          email
          tel
          iconUrl
          birthday
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
          "screenName" => be_a(String),
          "lastName" => be_a(String),
          "firstName" => be_a(String),
          "lastNameKanji" => be_a(String),
          "firstNameKanji" => be_a(String),
          "lastNameKana" => be_a(String),
          "firstNameKana" => be_a(String),
          "email" => be_a(String),
          "tel" => be_a(String),
          "iconUrl" => be_a(String),
          "birthday" => be_a(String)
        )
      )
    end
  end
end
