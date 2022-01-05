RSpec.describe("ArticleTranslation Query テスト") do
  describe "ArticleTranslation データを取得する" do
    let(:article) { FactoryBot.create(:article) }
    let(:article_translation) { FactoryBot.create(:article_translation, article_id: article.id) }

    let(:query) do
      data_id = Base64.strict_encode64("ArticleTranslation:#{article_translation.id}")
      %(query {
          articleTranslation(id: \"#{data_id}\") {
            id
          title
          body
          isDeleted
            }
          }
        )
    end

    subject(:result) do
      SOULsApiSchema.execute(query).as_json
    end

    it "return ArticleTranslation Data" do
      begin
        a1 = result.dig("data", "articleTranslation")
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
