RSpec.describe("ArticleSearch Resolver テスト") do
  describe "削除フラグ false の Article を返却する" do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { FactoryBot.create(:article, user_id: user.id) }

    let(:query) do
      %(query {
        articleSearch(filter: {
          isDeleted: false
      }) {
          edges {
            cursor
            node {
              id
              title
              body
              category
              tags
              slug
              published
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
      SOULsApiSchema.execute(query).as_json
    end

    it "return Article Data" do
      begin
        a1 = result.dig("data", "articleSearch", "edges")[0]["node"]
        raise unless a1.present?
      rescue StandardError
        raise(StandardError, result)
      end
      expect(a1).to(
        include(
          "id" => be_a(String),
          "title" => be_a(String),
          "body" => be_a(String),
          "category" => be_a(String),
          "tags" => be_all(String),
          "slug" => be_a(String),
          "published" => be_in([true, false]),
          "isDeleted" => be_in([true, false])
        )
      )
    end
  end
end
