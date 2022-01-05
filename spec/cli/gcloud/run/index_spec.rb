RSpec.describe(SOULs::CloudRun) do
  describe "list" do
    it "should call gcloud" do
      cli = SOULs::CloudRun.new
      allow(cli).to(receive(:system).and_return(true))
      expect(cli).to(receive(:system).with("gcloud run services list --platform managed"))

      expect(cli.list).to(eq(true))
    end
  end

  describe "get_endpoint" do
    it "should call gcloud" do
      cli = SOULs::CloudRun.new
      allow(cli).to(receive(:`).and_return(true))
      expect(cli).to(receive(:`).with("gcloud run services list  --platform managed | grep worker | awk '{print $4}'"))

      expect(cli.get_endpoint(worker_name: "worker")).to(eq(true))
    end
  end
end
