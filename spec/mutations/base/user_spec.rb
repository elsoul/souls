RSpec.describe "User Mutation テスト" do
  describe "User データを登録する" do
  let(:user) { FactoryBot.attributes_for(:user) }

  let(:mutation) do
    %(mutation {
      createUser(input: {
          uid: "#{user[:uid]}"
          createdAt: "#{user[:created_at]}"
          updatedAt: "#{user[:updated_at]}"
          memberName: "#{user[:member_name]}"
          memberRank: #{user[:member_rank]}
          memberBadge: #{user[:member_badge]}
          isMembership: #{user[:is_membership]}
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
          gender: "#{user[:gender]}"
          lang: "#{user[:lang]}"
          category: "#{user[:category]}"
          rolesMask: #{user[:roles_mask]}
          isDeleted: #{user[:is_deleted]}
        }) {
            userEdge {
          node {
              id
              created_at
              updated_at
              member_name
              member_rank
              member_badges
              is_membership
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
              gender
              lang
              category
              rolesMask
              isDeleted
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
    rescue
      raise StandardError, result
    end
    expect(a1).to include(
      "id" => be_a(String),
          "created_at" => be_a(String),
          "updated_at" => be_a(String),
          "member_name" => be_a(String),
          "member_rank" => be_a(Integer),
          "member_badges" => be_all(String),
          "is_membership" => be_in([true, false]),
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
        "birthday" => be_a(String),
        "gender" => be_a(String),
        "lang" => be_a(String),
        "category" => be_a(String),
        "rolesMask" => be_a(Integer),
        "isDeleted" => be_in([true, false]),
        )
    end
  end
end
