RSpec.describe("UserSearch Resolver テスト") do
  describe "削除フラグ false の User を返却する" do
    let!(:user) { FactoryBot.create(:user) }

    let(:query) do
      %(query {
        userSearch(filter: {
          isDeleted: false
      }) {
          edges {
            cursor
            node {
              id
              uid
              username
              email
              lang
              isDeleted
              }
            }
            nodes {
              id
            }
            pageInfo {
              endCursor
              hasNextPage
              startCursor
              hasPreviousPage
            }
          }
        }
      )
    end

    subject(:result) do
      SoulsApiSchema.execute(query).as_json
    end

    it "return User Data" do
      begin
        a1 = result.dig("data", "userSearch", "edges")[0]["node"]
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
