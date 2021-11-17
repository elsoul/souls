module Scaffold
  def self.scaffold_rspec_model
    <<~RSPECMODEL
    RSpec.describe "User Model テスト", type: :model do
      describe "User データを書き込む" do
        it "valid User Model" do
          expect(FactoryBot.build(:user)).to be_valid
        end
      end
    end
RSPECMODEL
  end
end
