RSpec.describe("ArticleCategory Query テスト") do
  describe "ArticleCategory データを取得する" do
    let!(:article_category) { FactoryBot.create(:article_category) }

    let(:query) do
      data_id = Base64.encode64("ArticleCategory:#{article_category.id}")
      %(query {
        articleCategory(id: \"#{data_id}\") {
          id
          name
          tags
          isDeleted
        }
      }
    )
    end

    subject(:result) do
      SoulsApiSchema.execute(query).as_json
    end

    it "return ArticleCategory Data" do
      begin
        a1 = result.dig("data", "articleCategory")
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
