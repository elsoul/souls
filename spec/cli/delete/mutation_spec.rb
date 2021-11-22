require_relative "./scaffolds/scaffold_delete"

RSpec.describe(Souls::Delete) do
  describe "mutation" do
    before do
      allow($stdout).to(receive(:write))
    end

    it "should delete file" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        allow(Souls).to(receive(:get_api_path).and_return("./"))

        file_dir = "./app/graphql/mutations/base/user/"
        file_name = "#{file_dir}create.rb"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        expect(File.exist?(file_name)).to(be(true))
        cli.mutation("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        allow(Souls).to(receive(:get_api_path).and_return("./"))

        file_dir = "./app/graphql/mutations/base/user/"
        file_name = "#{file_dir}create.rb"

        expect(File.exist?(file_name)).to(be(false))
        cli.mutation("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
