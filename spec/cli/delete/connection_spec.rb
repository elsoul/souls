require_relative "./scaffolds/scaffold_delete"

RSpec.describe(SOULs::Delete) do
  describe "connection" do
    it "should delete file" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = "./app/graphql/types/connections/"
        file_name = "#{file_dir}user_connection.rb"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        expect(File.exist?(file_name)).to(be(true))
        cli.connection("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = ".app/graphql/types/connections/"
        file_name = "#{file_dir}user_connection.rb"

        expect(File.exist?(file_name)).to(be(false))
        cli.connection("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
