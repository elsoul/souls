RSpec.describe(Souls) do
  it "has a version number" do
    expect(Souls::VERSION).not_to(be(nil))
  end

  describe "Configuration" do
    it "Should be able to set configuration" do
      Souls.configure do |config|
        config.strain = "api"
      end

      expect(Souls.configuration.strain).to(eq("api"))
    end

    it "has db/schema.rb file" do
      path = "./db/schema.rb"
      expect(File.exist?(path)).to(eq(true))
    end

    it "has user, article and article_category tables" do
      expect(Souls::Generate.get_tables).to(eq(%w[article_categories comments articles users]))
    end
  end
end
