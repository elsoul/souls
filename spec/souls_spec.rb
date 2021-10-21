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

    it "has user tables" do
      expect(Souls.get_tables).to(eq(["users"]))
    end
  end
end
