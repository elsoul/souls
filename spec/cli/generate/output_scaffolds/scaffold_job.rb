module OutputScaffold
  def self.scaffold_job
    <<~JOB
module Mutations
  class User < BaseMutation
    description "Job Description"
    field :response, String, null: false

    def resolve
      # Define Job Here

      { response: "Job done!" }
    rescue StandardError => e
      GraphQL::ExecutionError.new(e.to_s)
    end
  end
end
    JOB
  end
end
