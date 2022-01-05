RSpec.describe(SOULs::Pubsub) do
  describe "create_topic" do
    it "should send create topic" do
      cli = SOULs::Pubsub.new

      allow(cli).to(receive(:options).and_return({ topic_name: "name" }))
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(receive(:system).with("gcloud pubsub topics create name"))

      cli.create_topic
    end
  end

  describe "topic_list" do
    it "should call gcloud with topics list" do
      cli = SOULs::Pubsub.new

      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(receive(:system).with("gcloud pubsub topics list"))

      cli.topic_list
    end
  end
end
