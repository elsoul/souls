module OutputScaffold
  def self.scaffold_connection_rbs
    <<~CONNECTIONRBS
module Types
  class UserConnection < Types::BaseConnection
    def self.edge_type: (*untyped) -> untyped
  end
end
    CONNECTIONRBS
  end
end
