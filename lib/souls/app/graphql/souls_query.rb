module SOULs
  class SOULsQuery < GraphQL::Schema::Resolver
    @schedule = nil
    class << self
      attr_accessor :schedule
    end

    def souls_post(url:, payload: {}, content_type: "application/json")
      response = Faraday.post(url, payload.to_json, "Content-Type": content_type)
      response.body
    end

    def souls_check_user_permissions(user, obj, method)
      raise(StandardError, "Invalid or Missing Token") unless user

      policy_class = obj.class.name + "Policy"
      policy_clazz = policy_class.constantize.new(user, obj)
      permission = policy_clazz.public_send(method)
      raise(Pundit::NotAuthorizedError, "permission error!") unless permission
    end

    def self.cron(schedule)
      self.schedule = schedule
    end

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
