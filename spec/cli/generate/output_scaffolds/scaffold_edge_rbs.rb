module OutputScaffold
  def self.scaffold_edge_rbs
    <<~EDGERBS
module Types
  class UserEdge < BaseObject
    def self.edge_type: (*untyped) -> untyped
    def self.node_type: (*untyped) -> untyped
    def self.global_id_field: (*untyped) -> untyped
    def self.connection_type: ()-> untyped
  end
end
    EDGERBS
  end
end
