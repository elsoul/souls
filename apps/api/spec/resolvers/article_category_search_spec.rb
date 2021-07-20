RSpec.describe("ArticleCategorySearch Resolver テスト") do
  describe "削除フラグ false の ArticleCategory を返却する" do
    let!(:article_category) { FactoryBot.create(:article_category) }

    let(:query) do
      %(query {
        articleCategorySearch(filter: {
          isDeleted: false
      }) {
          edges {
            cursor
            node {
              id
              name
              tags
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

    it "return ArticleCategory Data" do
      begin
        a1 = result.dig("data", "articleCategorySearch", "edges")[0]["node"]
        raise unless a1.present?
      rescue StandardError
        raise(StandardError, result)
      end
      expect(a1).to(
        include(
          "id" => be_a(String),
          "name" => be_a(String),
          "tags" => be_all(String),
          "isDeleted" => be_in([true, false])
        )
      )
    end
  end
end
