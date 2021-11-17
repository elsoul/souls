require_relative "./scaffolds/scaffold_create_migration_rbs"

RSpec.describe(Souls::DB) do
  describe "create_migration_rbs" do
    it "should create correct file" do
      FakeFS.with_fresh do
        cli = Souls::DB.new
        file_dir = "./sig/api/db/migrate"
        FileUtils.mkdir_p(file_dir)

        allow(Souls).to(receive(:get_mother_path).and_return("./"))

        cli.create_migration_rbs("user")
        output = File.read("#{file_dir}/create_users.rbs")

        expected_output = Scaffold.scaffold_create_migration_rbs
        expect(output).to(eq(expected_output))
      end
    end
  end
end
