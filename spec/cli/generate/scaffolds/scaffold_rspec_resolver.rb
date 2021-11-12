module Scaffold
  def self.scaffold_rspec_resolver
    <<~RSPECRESOLVER
RSpec.describe "UserSearch Resolver テスト" do
  describe "削除フラグ false の User を返却する" do
RSPECRESOLVER
  end
end
