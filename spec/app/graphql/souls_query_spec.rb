module Queries
  class ExampleQuery < SOULs::SOULsQuery
    cron "1 0 * * *"
    def resolve
      true
    end
  end

  class ExampleQuery2 < SOULs::SOULsQuery
    def resolve
      true
    end
  end

  class ExampleQuery3 < SOULs::SOULsQuery
    cron "1 5 * * *"
    def resolve
      true
    end
  end
end

RSpec.describe(SOULs::SOULsQuery) do
  describe "self.cron" do
    it "should set schedule for children" do
      expect(Queries::ExampleQuery.schedule).to(eq("1 0 * * *"))
    end
  end

  describe "self.all_schedules" do
    it "should get all schedules that have cron" do
      expected = { ExampleQuery: "1 0 * * *", ExampleQuery3: "1 5 * * *" }
      expect(SOULs::SOULsQuery.all_schedules).to(eq(expected))
    end
  end
end
