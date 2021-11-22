require_relative "./scaffolds/scaffold_delete"

RSpec.describe(Souls::Delete) do
  describe "query" do
    before do
      allow($stdout).to(receive(:write))
    end

    it "should delete file" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        file_dir = "./app/graphql/queries/"
        file_name = "#{file_dir}user*.rb"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        expect(File.exist?(file_name)).to(be(true))
        cli.query("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        file_dir = "./app/graphql/queries/"
        file_name = "#{file_dir}user*.rb"

        expect(File.exist?(file_name)).to(be(false))
        cli.query("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
