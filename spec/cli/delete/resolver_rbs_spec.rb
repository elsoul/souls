require_relative "./scaffolds/scaffold_delete"

RSpec.describe(Souls::Delete) do
  describe "resolver_rbs" do
    it "should delete file" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        allow(Souls).to(receive(:get_mother_path).and_return("./"))
        file_dir = "./sig/api/app/graphql/resolvers/"
        file_name = "#{file_dir}user_search.rbs"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        expect(File.exist?(file_name)).to(be(true))
        cli.resolver_rbs("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        allow(Souls).to(receive(:get_mother_path).and_return("./"))
        file_dir = "./sig/api/app/graphql/resolvers/"
        file_name = "#{file_dir}user_search.rbs"

        expect(File.exist?(file_name)).to(be(false))
        cli.resolver_rbs("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
