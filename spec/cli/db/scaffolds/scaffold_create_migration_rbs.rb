module Scaffold
  def self.scaffold_create_migration_rbs
    <<~CREATEMIGRATIONRBS
class CreateUsers
  def change: () -> untyped
  def create_table: (:users) { (untyped) -> untyped } -> untyped
  def add_index: (:users, *untyped) -> untyped
end
CREATEMIGRATIONRBS
  end
end
