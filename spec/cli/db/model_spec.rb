require_relative "./scaffolds/scaffold_model"

RSpec.describe(Souls::DB) do
  describe "model_spec" do
    it "should create correct file" do
      FakeFS.with_fresh do
        cli = Souls::DB.new
        file_dir = "./app/models"
        FileUtils.mkdir_p(file_dir)

        allow(Souls).to(receive(:get_mother_path).and_return("./"))

        cli.model("user")
        output = File.read("#{file_dir}/user.rb")

        expected_output = Scaffold.scaffold_model
        expect(output).to(eq(expected_output))
      end
    end
  end
end
