require_relative "./scaffolds/scaffold_delete"

RSpec.describe(SOULs::Delete) do
  describe "resolver" do
    before do
      allow($stdout).to(receive(:write))
    end

    it "should delete file" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = "./app/graphql/resolvers/"
        file_name = "#{file_dir}user_search.rb"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        expect(File.exist?(file_name)).to(be(true))
        cli.resolver("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = "./app/graphql/resolvers/"
        file_name = "#{file_dir}user_search.rb"

        expect(File.exist?(file_name)).to(be(false))
        cli.resolver("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
