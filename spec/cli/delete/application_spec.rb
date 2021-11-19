RSpec.describe(Souls::Delete) do
  before do
    allow($stdout).to(receive(:write))
  end

  describe "scaffold" do
    it "Should call run_rbs_scaffold with rbs" do
      cli = Souls::Delete.new

      allow_any_instance_of(Souls::Delete).to(receive(:run_rbs_scaffold).and_return(true))

      expect_any_instance_of(Souls::Delete).to(receive(:run_rbs_scaffold).with({ class_name: "user" }))

      cli.invoke(:scaffold, ["users"], { rbs: true })
    end

    it "Should call run_scaffold without rbs" do
      cli = Souls::Delete.new

      allow_any_instance_of(Souls::Delete).to(receive(:run_scaffold).and_return(true))

      expect_any_instance_of(Souls::Delete).to(receive(:run_scaffold).with({ class_name: "user" }))

      cli.invoke(:scaffold, ["users"], { rbs: false })
    end
  end

  describe "scaffold_all" do
    it "should call scaffold for each table" do
      cli = Souls::Delete.new

      allow(Souls).to(receive(:get_tables)).and_return(%w[apple])
      allow_any_instance_of(Souls::Delete).to(receive(:run_scaffold).and_return(true))

      expect_any_instance_of(Souls::Delete).to(receive(:run_scaffold))

      cli.invoke(:scaffold_all, [], { rbs: false })
    end

    it "should only call _rbs with rbs option" do
      cli = Souls::Delete.new

      allow(Souls).to(receive(:get_tables)).and_return(%w[apple])
      allow_any_instance_of(Souls::Delete).to(receive(:run_rbs_scaffold).and_return(true))

      expect_any_instance_of(Souls::Delete).to(receive(:run_rbs_scaffold))

      cli.invoke(:scaffold_all, [], { rbs: true })
    end
  end

  describe "run_scaffold" do
    it "should call a bunch of methods" do
      cli = Souls::Delete.new
      allow(cli).to(receive(:type).and_return(true))
      allow(cli).to(receive(:type_rbs).and_return(true))
      allow(cli).to(receive(:query).and_return(true))
      allow(cli).to(receive(:query_rbs).and_return(true))
      allow(cli).to(receive(:mutation).and_return(true))
      allow(cli).to(receive(:mutation_rbs).and_return(true))
      allow(cli).to(receive(:edge).and_return(true))
      allow(cli).to(receive(:edge_rbs).and_return(true))
      allow(cli).to(receive(:connection).and_return(true))
      allow(cli).to(receive(:connection_rbs).and_return(true))
      allow(cli).to(receive(:resolver).and_return(true))
      allow(cli).to(receive(:resolver_rbs).and_return(true))
      allow(cli).to(receive(:rspec_factory).and_return(true))
      allow(cli).to(receive(:rspec_mutation).and_return(true))
      allow(cli).to(receive(:rspec_query).and_return(true))
      allow(cli).to(receive(:rspec_resolver).and_return(true))

      expect(cli).to(receive(:type).with("user"))
      expect(cli).to(receive(:type_rbs).with("user"))
      expect(cli).to(receive(:query).with("user"))
      expect(cli).to(receive(:query_rbs).with("user"))
      expect(cli).to(receive(:mutation).with("user"))
      expect(cli).to(receive(:mutation_rbs).with("user"))
      expect(cli).to(receive(:edge).with("user"))
      expect(cli).to(receive(:edge_rbs).with("user"))
      expect(cli).to(receive(:connection).with("user"))
      expect(cli).to(receive(:connection_rbs).with("user"))
      expect(cli).to(receive(:resolver).with("user"))
      expect(cli).to(receive(:resolver_rbs).with("user"))
      expect(cli).to(receive(:rspec_factory).with("user"))
      expect(cli).to(receive(:rspec_mutation).with("user"))
      expect(cli).to(receive(:rspec_query).with("user"))
      expect(cli).to(receive(:rspec_resolver).with("user"))

      cli.__send__(:run_scaffold, **{ class_name: "user" })
    end
  end

  describe "run_rbs_scaffold" do
    it "should call rbs methods" do
      cli = Souls::Delete.new
      allow(cli).to(receive(:type_rbs).and_return(true))
      allow(cli).to(receive(:query_rbs).and_return(true))
      allow(cli).to(receive(:mutation_rbs).and_return(true))
      allow(cli).to(receive(:edge_rbs).and_return(true))
      allow(cli).to(receive(:connection_rbs).and_return(true))
      allow(cli).to(receive(:resolver_rbs).and_return(true))

      expect(cli).to(receive(:type_rbs).with("user"))
      expect(cli).to(receive(:query_rbs).with("user"))
      expect(cli).to(receive(:mutation_rbs).with("user"))
      expect(cli).to(receive(:edge_rbs).with("user"))
      expect(cli).to(receive(:connection_rbs).with("user"))
      expect(cli).to(receive(:resolver_rbs).with("user"))

      cli.__send__(:run_rbs_scaffold, **{ class_name: "user" })
    end
  end
end
