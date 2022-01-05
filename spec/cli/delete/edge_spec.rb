require_relative "./scaffolds/scaffold_delete"

RSpec.describe(SOULs::Delete) do
  describe "edge" do
    it "should delete file" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = "./app/graphql/types/edges/"
        file_name = "#{file_dir}user_edge.rb"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        expect(File.exist?(file_name)).to(be(true))
        cli.edge("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = "./app/graphql/types/edges/"
        file_name = "#{file_dir}user_edge.rb"

        expect(File.exist?(file_name)).to(be(false))
        cli.edge("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
