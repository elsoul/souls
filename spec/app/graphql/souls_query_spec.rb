module Queries
  class ExampleQuery < Souls::SoulsQuery
    cron "1 0 * * *"
    def resolve
      true
    end
  end

  class ExampleQuery2 < Souls::SoulsQuery
    def resolve
      true
    end
  end

  class ExampleQuery3 < Souls::SoulsQuery
    cron "1 5 * * *"
    def resolve
      true
    end
  end
end

RSpec.describe(Souls::SoulsQuery) do
  describe "self.cron" do
    it "should set schedule for children" do
      expect(Queries::ExampleQuery.schedule).to(eq("1 0 * * *"))
    end
  end

  describe "self.all_schedules" do
    it "should get all schedules that have cron" do
      expected = { ExampleQuery: "1 0 * * *", ExampleQuery3: "1 5 * * *" }
      expect(Souls::SoulsQuery.all_schedules).to(eq(expected))
    end
  end
end
