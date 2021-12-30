RSpec.describe("Article Query テスト") do
  describe "Article データを取得する" do
    let(:user) { FactoryBot.create(:user) }
    let(:article) { FactoryBot.create(:article, user_id: user.id) }

    let(:query) do
      data_id = Base64.encode64("Article:#{article.id}")
      %(query {
          article(id: \"#{data_id}\") {
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
        )
    end

    subject(:result) do
      SoulsApiSchema.execute(query).as_json
    end

    it "return Article Data" do
      begin
        a1 = result.dig("data", "article")
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
