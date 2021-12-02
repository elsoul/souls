RSpec.describe(Souls::CloudScheduler) do
  describe "awake" do
    before :each do
      allow($stdout).to(receive(:write))
    end

    it "should set ping every 15 minutes" do
      cli = Souls::CloudScheduler.new
      allow(Souls.configuration).to(receive(:app).and_return("test-app"))
      allow_any_instance_of(Souls::CloudScheduler).to(receive(:system).and_return(true))
      expect_any_instance_of(Souls::CloudScheduler).to(
        receive(:system).with(
          "gcloud scheduler jobs create http test-app-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri abc.com --http-method GET"
        )
      )

      expect(cli.invoke(:awake, [], { url: "abc.com" })).to(eq(true))
    end
  end

  describe "sync_schedules" do
    before :each do
      allow($stdout).to(receive(:write))
    end
    it "should work with no schedules" do
      cli = Souls::CloudScheduler.new
      allow(cli).to(receive(:require).and_return(true))
      allow_any_instance_of(Souls::Gcloud).to(receive(:config_set).and_return(true))
      allow(cli).to(receive(:current_schedules).and_return([]))
      allow(Queries::BaseQuery).to(receive(:all_schedules).and_return([]))

      expect(cli.sync_schedules).to(eq([]))
    end

    it "should call system with schedules" do
      cli = Souls::CloudScheduler.new
      allow(cli).to(receive(:require).and_return(true))
      allow_any_instance_of(Souls::Gcloud).to(receive(:config_set).and_return(true))
      allow(cli).to(receive(:current_schedules).and_return({ souls_a: 1, souls_b: 2 }))
      allow(Queries::BaseQuery).to(receive(:all_schedules).and_return({ a: 1, c: 3 }))

      allow(cli).to(receive(:system).and_return(true))

      expect(cli.sync_schedules).to(eq({ souls_b: 2 }))
    end
  end

  describe "current_schedules" do
    it "should retrieve current schedules from gcloud" do
      cli = Souls::CloudScheduler.new
      allow(cli).to(
        receive(:`).and_return(
          "ID                         LOCATION      SCHEDULE (TZ)                   TARGET_TYPE  STATE"
        )
      )

      result = cli.__send__(:current_schedules)
      expect(result).to(eq({}))
    end
  end
end

module Queries
  module BaseQuery
  end
end
