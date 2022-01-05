require_relative "./scaffolds/scaffold_delete"

RSpec.describe(SOULs::Delete) do
  describe "type_rbs" do
    it "should delete file" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        allow(SOULs).to(receive(:get_mother_path).and_return("./"))
        file_dir = "./sig/api/app/graphql/types/"
        file_name = "#{file_dir}user_type.rbs"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        expect(File.exist?(file_name)).to(be(true))
        cli.type_rbs("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        allow(SOULs).to(receive(:get_mother_path).and_return("./"))
        file_dir = "./sig/api/app/graphql/types/"
        file_name = "#{file_dir}user_type.rbs"

        expect(File.exist?(file_name)).to(be(false))
        cli.type_rbs("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
