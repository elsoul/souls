module Souls
  class SoulsQuery < GraphQL::Schema::Resolver
    @schedule = nil
    class << self
      attr_accessor :schedule
    end

    desc "hello"
    def self.cron(schedule)
      self.schedule = schedule
    end

    desc "hello"
    def self.all_schedules
      schedule_list = {}
      Queries.constants.select { |c| Queries.const_get(c).is_a?(Class) }
             .each do |clname|
        next if clname == :BaseQuery

        job_schedule = Queries.const_get(clname).schedule
        schedule_list[clname] = job_schedule unless job_schedule.nil?
      end
      schedule_list
    end
  end
end

module Queries
end
