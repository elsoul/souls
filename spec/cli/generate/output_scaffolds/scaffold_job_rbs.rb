module OutputScaffold
  def self.scaffold_job_rbs
    <<~JOBRBS
module Mutations
  String: String
  class User < BaseMutation
    def self.description: (String) -> untyped
    def self.field: (:response, String, null: false) -> untyped
  end
end
    JOBRBS
  end
end
