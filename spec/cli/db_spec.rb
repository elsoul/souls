RSpec.describe(Souls::CLI) do
  describe "souls db:$METHOD command" do
    it "souls db:migrate" do
      a1 = Souls::CLI.new.invoke(:migrate, [], {})
      expect(a1).to(eq(true))
    end
  end
end