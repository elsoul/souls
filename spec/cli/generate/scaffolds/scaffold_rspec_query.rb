module OutputScaffold
  def self.scaffold_rspec_query
    <<~RSPECQUERY
RSpec.describe "User Query テスト" do
  describe "User データを取得する" do
RSPECQUERY
  end
end
