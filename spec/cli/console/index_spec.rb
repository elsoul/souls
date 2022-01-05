RSpec.describe(SOULs::CLI) do
  describe "console" do
    it "Should start the console for production with production" do
      cli = SOULs::CLI.new
      cli.options = { env: "production" }
      allow(cli).to(receive(:system).with("RACK_ENV=production bundle exec irb").and_return(true))
      result = cli.console
      expect(result).to(eq(true))
    end

    it "Should start the console with other arguments" do
      cli = SOULs::CLI.new
      cli.options = { env: "development" }
      allow(cli).to(receive(:system).with("bundle exec irb").and_return(true))
      result = cli.console
      expect(result).to(eq(true))
    end
  end
end
