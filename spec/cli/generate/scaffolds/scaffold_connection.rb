module Scaffold
  def self.scaffold_connection
    <<~CONNECTION
      class Types::UserConnection < Types::BaseConnection
        edge_type(Types::UserEdge)
      end
    CONNECTION
  end
end
