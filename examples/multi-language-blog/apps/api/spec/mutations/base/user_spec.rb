RSpec.describe("User Mutation テスト") do
  describe "User データを登録する" do
    let(:user) { FactoryBot.attributes_for(:user) }

    let(:mutation) do
      %(mutation {
        createUser(input: {
          uid: "#{user[:uid]}"
          username: "#{user[:username]}"
          email: "#{user[:email]}"
          lang: "#{user[:lang]}"
          isDeleted: #{user[:is_deleted]}
        }) {
            userEdge {
          node {
              id
              uid
              username
              email
              lang
              isDeleted
              }
            }
          }
        }
      )
    end

    subject(:result) do
      SOULsApiSchema.execute(mutation).as_json
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
