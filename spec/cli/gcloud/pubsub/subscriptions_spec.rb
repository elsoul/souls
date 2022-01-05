RSpec.describe(SOULs::Pubsub) do
  describe "create_subscription" do
    it "should call gcloud with options" do
      cli = SOULs::Pubsub.new

      allow(cli).to(receive(:options).and_return({ topic_name: "name", endpoint: "endpoint" }))
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(
        receive(:system).with(
          "gcloud pubsub subscriptions create name-sub \
            --topic name \
            --topic-project el-quest \
            --push-auth-service-account souls@el-quest.iam.gserviceaccount.com \
            --push-endpoint endpoint \
            --expiration-period never"
        )
      )

      cli.create_subscription
    end
  end

  describe "subscription_list" do
    it "should call gcloud" do
      cli = SOULs::Pubsub.new
      allow(cli).to(receive(:system).and_return(true))
      expect(cli).to(receive(:system).with("gcloud pubsub subscriptions list"))
      cli.subscription_list
    end
  end

  describe "update_subscription" do
    it "should call gcloud and update subscription" do
      cli = SOULs::Pubsub.new

      allow(cli).to(receive(:options).and_return({ topic_name: "name", endpoint: "endpoint" }))
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(receive(:system).with("gcloud pubsub subscriptions update name-sub --push-endpoint endpoint "))
      cli.update_subscription
    end
  end
end
