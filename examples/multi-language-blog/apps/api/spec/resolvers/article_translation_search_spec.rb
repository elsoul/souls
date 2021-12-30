RSpec.describe("ArticleTranslationSearch Resolver テスト") do
  describe "削除フラグ false の ArticleTranslation を返却する" do
    let(:article) { FactoryBot.create(:article) }
    let!(:article_translation) { FactoryBot.create(:article_translation, article_id: article.id) }

    let(:query) do
      %(query {
        articleTranslationSearch(filter: {
          isDeleted: false
      }) {
          edges {
            cursor
            node {
              id
              title
              body
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

    it "return ArticleTranslation Data" do
      begin
        a1 = result.dig("data", "articleTranslationSearch", "edges")[0]["node"]
        raise unless a1.present?
      rescue StandardError
        raise(StandardError, result)
      end
      expect(a1).to(
        include(
          "id" => be_a(String),
          "title" => be_a(String),
          "body" => be_a(String),
          "isDeleted" => be_in([true, false])
        )
      )
    end
  end
end
