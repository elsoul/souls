RSpec.describe("ArticleTranslation Model テスト", type: :model) do
  describe "ArticleTranslation データを書き込む" do
    it "valid ArticleTranslation Model" do
      expect(FactoryBot.build(:article_translation)).to(be_valid)
    end
  end
end
