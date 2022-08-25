module Scaffold
  def self.scaffold_rspec_mutation
    <<~RSPECMUTATION
      RSpec.describe "User Mutation テスト" do
        describe "User データを登録する" do
    RSPECMUTATION
  end
end
