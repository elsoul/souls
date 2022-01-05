require_relative "./scaffolds/scaffold_create_migration"

RSpec.describe(SOULs::DB) do
  describe "create_migration" do
    it "should create correct file" do
      FakeFS.with_fresh do
        cli = SOULs::DB.new
        file_dir = "./db/migrate"
        FileUtils.mkdir_p(file_dir)
        FileUtils.touch("#{file_dir}/create_users.rb")

        allow(SOULs).to(receive(:get_mother_path).and_return("./"))

        cli.create_migration("user")
        output = File.read("#{file_dir}/create_users.rb")

        expected_output = Scaffold.scaffold_create_migration
        expect(output).to(eq(expected_output))
      end
    end
  end
end
