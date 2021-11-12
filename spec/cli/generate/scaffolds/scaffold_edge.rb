module Scaffold
  def self.scaffold_edge
    <<~EDGE
class Types::UserEdge < Types::BaseEdge
  node_type(Types::UserType)
end
EDGE
  end
end
