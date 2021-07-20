RSpec.describe("ArticleCategory Model テスト", type: :model) do
  describe "ArticleCategory データを書き込む" do
    it "valid ArticleCategory Model" do
      expect(FactoryBot.build(:article_category)).to(be_valid)
    end
  end
end
