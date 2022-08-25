RSpec.describe(SOULs::Delete) do
  before do
    allow($stdout).to(receive(:write))
  end

  describe "run_scaffold" do
    it "should call a bunch of methods" do
      cli = SOULs::Delete.new
      allow(cli).to(receive(:type).and_return(true))
      allow(cli).to(receive(:query).and_return(true))
      allow(cli).to(receive(:mutation).and_return(true))
      allow(cli).to(receive(:edge).and_return(true))
      allow(cli).to(receive(:connection).and_return(true))
      allow(cli).to(receive(:resolver).and_return(true))
      allow(cli).to(receive(:rspec_factory).and_return(true))
      allow(cli).to(receive(:rspec_mutation).and_return(true))
      allow(cli).to(receive(:rspec_query).and_return(true))
      allow(cli).to(receive(:rspec_resolver).and_return(true))

      expect(cli).to(receive(:type).with("user"))
      expect(cli).to(receive(:query).with("user"))
      expect(cli).to(receive(:mutation).with("user"))
      expect(cli).to(receive(:edge).with("user"))
      expect(cli).to(receive(:connection).with("user"))
      expect(cli).to(receive(:resolver).with("user"))
      expect(cli).to(receive(:rspec_factory).with("user"))
      expect(cli).to(receive(:rspec_mutation).with("user"))
      expect(cli).to(receive(:rspec_query).with("user"))
      expect(cli).to(receive(:rspec_resolver).with("user"))

      cli.__send__(:run_scaffold, **{ class_name: "user" })
    end
  end
end
