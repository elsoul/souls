RSpec.describe("ArticleCategory Mutation テスト") do
  describe "ArticleCategory データを登録する" do
    let(:article_category) { FactoryBot.attributes_for(:article_category) }

    let(:mutation) do
      %(mutation {
        createArticleCategory(input: {
          name: "#{article_category[:name]}"
          tags: #{article_category[:tags]}
          isDeleted: #{article_category[:is_deleted]}
        }) {
            articleCategoryEdge {
          node {
              id
              name
              tags
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

    it "return ArticleCategory Data" do
      begin
        a1 = result.dig("data", "createArticleCategory", "articleCategoryEdge", "node")
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
