module Scaffold
  def self.scaffold_job_rbs
    <<~JOBRBS
module Queries
  class User < BaseQuery
    def self.description: (String) -> untyped
    def self.field: (:response, String, null: false) -> untyped
    def self.type: (untyped, null: false) -> untyped
  end
end
    JOBRBS
  end
end
