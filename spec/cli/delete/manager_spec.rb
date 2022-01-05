require_relative "./scaffolds/scaffold_delete"

RSpec.describe(SOULs::Delete) do
  describe "migration" do
    before do
      allow($stdout).to(receive(:write))
    end

    it "should delete file" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = "./app/graphql/mutations/managers/user_manager/"
        file_name = "#{file_dir}create.rb"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        allow_any_instance_of(SOULs::Delete).to(receive(:manager_rbs)).and_return(true)
        allow_any_instance_of(SOULs::Delete).to(receive(:rspec_manager)).and_return(true)

        expect(File.exist?(file_name)).to(be(true))
        cli.invoke(:manager, ["user"], { mutation: "create" })
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        file_dir = "./app/graphql/mutations/managers/user_manager/"
        file_name = "#{file_dir}create.rb"

        allow_any_instance_of(SOULs::Delete).to(receive(:manager_rbs)).and_return(true)
        allow_any_instance_of(SOULs::Delete).to(receive(:rspec_manager)).and_return(true)

        expect(File.exist?(file_name)).to(be(false))
        cli.invoke(:manager, ["user"], { mutation: "create" })
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
