require_relative "./scaffolds/scaffold_rspec_model"

RSpec.describe(Souls::DB) do
  describe "rspec_model" do
    it "should create correct file" do
      FakeFS.with_fresh do
        cli = Souls::DB.new
        file_dir = "./spec/models"
        FileUtils.mkdir_p(file_dir)

        allow(Souls).to receive(:get_mother_path).and_return("./")

        cli.rspec_model("user")
        output = File.read("#{file_dir}/user_spec.rb")
        
        expected_output = Scaffold.scaffold_rspec_model
        expect(output).to eq(expected_output)
      end
    end
  end
end