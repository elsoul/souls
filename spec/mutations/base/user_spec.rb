RSpec.describe("User Mutation テスト") do
  describe "User データを登録する" do
    let!(:user) { FactoryBot.attributes_for(:user) }
    let!(:retailer) { FactoryBot.create(:retailer) }

    let(:mutation) do
      %(mutation {
        createUser(input: {
          retailerId: "#{get_global_key('Retailer', retailer.id)}"
          memberBadge: #{user[:member_badge]}
          memberName: "#{user[:member_name]}"
          memberRank: #{user[:member_rank]}
          uid: "#{user[:uid]}"
          username: "#{user[:username]}"
          screenName: "#{user[:screen_name]}"
          lastName: "#{user[:last_name]}"
          firstName: "#{user[:first_name]}"
          lastNameKanji: "#{user[:last_name_kanji]}"
          firstNameKanji: "#{user[:first_name_kanji]}"
          lastNameKana: "#{user[:last_name_kana]}"
          firstNameKana: "#{user[:first_name_kana]}"
          email: "#{user[:email]}"
          tel: "#{user[:tel]}"
          iconUrl: "#{user[:icon_url]}"
          birthday: "#{user[:birthday]}"
        }) {
            userEdge {
          node {
              id
              member_name
              member_rank
              member_badges
              uidAC
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
          }
        }
      )
    end

    subject(:result) do
      SoulsApiSchema.execute(mutation).as_json
    end

    it "return User Data" do
      begin
        a1 = result.dig("data", "createUser", "userEdge", "node")
        raise unless a1.present?
      rescue StandardError
        raise(StandardError, result)
      end
      expect(a1).to(
        include(
          "id" => be_a(String),
          "member_name" => be_a(String),
          "member_rank" => be_a(Integer),
          "member_badges" => be_all(String),
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
