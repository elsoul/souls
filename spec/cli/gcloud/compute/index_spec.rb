require_relative "scaffolds/api_yml_scaffold"

RSpec.describe(Souls::Compute) do
  describe "index" do
    describe "update_workflows" do
      before(:each) do
        allow(Souls.configuration).to(receive(:app).and_return("app"))
        allow(Souls).to(receive(:get_mother_path).and_return("./"))
      end

      it "should add connector to api" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(".github/workflows/")
          File.open(".github/workflows/api.yml", "w") { |f| f.write(Scaffold.scaffold_api_yml) }

          cli = Souls::Compute.new
          cli.__send__(:update_workflows)

          output = File.read(".github/workflows/api.yml")

          expect(output).to(eq(Scaffold.scaffold_api_yml_api))
        end
      end

      it "should add egress to worker" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(".github/workflows/")
          File.open(".github/workflows/worker.yml", "w") { |f| f.write(Scaffold.scaffold_api_yml) }

          cli = Souls::Compute.new
          cli.__send__(:update_workflows)

          output = File.read(".github/workflows/worker.yml")

          expect(output).to(eq(Scaffold.scaffold_api_yml_worker))
        end
      end
    end
  end
end
