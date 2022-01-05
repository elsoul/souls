require_relative "./scaffolds/scaffold_model_rbs"

RSpec.describe(SOULs::DB) do
  describe "model_rbs" do
    it "should create correct file" do
      FakeFS.with_fresh do
        cli = SOULs::DB.new
        file_dir = "./sig/api/app/models"
        FileUtils.mkdir_p(file_dir)

        allow(SOULs).to(receive(:get_mother_path).and_return("./"))

        cli.model_rbs("user")
        output = File.read("#{file_dir}/user.rbs")

        expected_output = Scaffold.scaffold_model_rbs
        expect(output).to(eq(expected_output))
      end
    end
  end
end
