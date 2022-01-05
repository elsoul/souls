RSpec.describe("ArticleTranslation Mutation テスト") do
  describe "ArticleTranslation データを登録する" do
    let(:article) { FactoryBot.create(:article) }
    let(:article_translation) do
      FactoryBot.attributes_for(:article_translation, article_id: get_global_key("Article", article.id))
    end

    let(:mutation) do
      %(mutation {
        createArticleTranslation(input: {
          articleId: "#{article_translation[:article_id]}"
          title: "#{article_translation[:title]}"
          body: "#{article_translation[:body]}"
          isDeleted: #{article_translation[:is_deleted]}
        }) {
            articleTranslationEdge {
          node {
              id
              title
              body
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

    it "return ArticleTranslation Data" do
      begin
        a1 = result.dig("data", "createArticleTranslation", "articleTranslationEdge", "node")
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
