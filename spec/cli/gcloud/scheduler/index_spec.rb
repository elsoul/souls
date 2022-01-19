RSpec.describe(SOULs::CloudScheduler) do
  describe "awake" do
    before :each do
      allow($stdout).to(receive(:write))
    end

    it "should set ping every 15 minutes" do
      cli = SOULs::CloudScheduler.new
      allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
      allow_any_instance_of(SOULs::CloudScheduler).to(receive(:system).and_return(true))
      expect_any_instance_of(SOULs::CloudScheduler).to(
        receive(:system).with(
          "gcloud scheduler jobs create http test-app-awake \
            --schedule '0,10,20,30,40,50 * * * *' --uri abc.com --http-method GET"
        )
      )

      expect(cli.invoke(:awake, ["abc.com"], {})).to(eq(true))
    end
  end

  describe "sync_schedules" do
    before :each do
      allow($stdout).to(receive(:write))
    end
    it "should work with no schedules" do
      cli = SOULs::CloudScheduler.new
      allow(cli).to(receive(:require).and_return(true))
      allow_any_instance_of(SOULs::Gcloud).to(receive(:config_set).and_return(true))
      allow(cli).to(receive(:current_schedules).and_return([]))
      allow(Queries::BaseQuery).to(receive(:all_schedules).and_return([]))

      expect(cli.sync_schedules).to(eq([]))
    end

    it "should call system with schedules" do
      cli = SOULs::CloudScheduler.new
      allow(cli).to(receive(:require).and_return(true))
      allow_any_instance_of(SOULs::Gcloud).to(receive(:config_set).and_return(true))
      allow(cli).to(receive(:current_schedules).and_return({ souls_a: 1, souls_b: 2 }))
      allow(Queries::BaseQuery).to(receive(:all_schedules).and_return({ a: 2, c: 3 }))

      allow(cli).to(receive(:system).and_return(true))

      expect(cli.sync_schedules).to(eq({ souls_a: 1, souls_b: 2 }))
    end
  end

  describe "current_schedules" do
    it "should retrieve current schedules from gcloud" do
      cli = SOULs::CloudScheduler.new
      allow(cli).to(
        receive(:`).and_return(<<~SCHEDULESLIST))
          ID                         LOCATION      SCHEDULE (TZ)                   TARGET_TYPE  STATE\\n
          GemInstall                 europe-west1  1/2 * * * * (Europe/Amsterdam)  HTTP         PAUSED
        SCHEDULESLIST

      result = cli.__send__(:current_schedules)
      expect(result).to(eq({ GemInstall: "1/2 * * * *" }))
    end
  end
end

module Queries
  module BaseQuery
  end
end
