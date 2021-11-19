require_relative "./scaffolds/scaffold_delete"

RSpec.describe(Souls::Delete) do
  before do
    allow($stdout).to(receive(:write))
  end

  describe "job" do
    it "should delete file" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        file_dir = "./app/graphql/queries/"
        file_name = "#{file_dir}user.rb"
        FileUtils.mkdir_p(file_dir)
        File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

        allow_any_instance_of(Souls::Delete).to(receive(:job_rbs)).and_return(true)
        allow_any_instance_of(Souls::Delete).to(receive(:rspec_job)).and_return(true)

        expect(File.exist?(file_name)).to(be(true))
        cli.job("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = Souls::Delete.new

        file_dir = "./app/graphql/queries/"
        file_name = "#{file_dir}user.rb"

        allow_any_instance_of(Souls::Delete).to(receive(:job_rbs)).and_return(true)
        allow_any_instance_of(Souls::Delete).to(receive(:rspec_job)).and_return(true)

        expect(File.exist?(file_name)).to(be(false))
        cli.job("user")
        expect(File.exist?(file_name)).to(be(false))
      end
    end
  end
end
