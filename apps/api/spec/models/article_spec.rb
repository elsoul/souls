RSpec.describe("Article Model テスト", type: :model) do
  describe "Article データを書き込む" do
    it "valid Article Model" do
      expect(FactoryBot.build(:article)).to(be_valid)
    end
  end
end
