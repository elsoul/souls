require_relative "./scaffolds/scaffold_rspec_job"

RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Job" do

    let(:class_name) { "user" }
    let(:file_name) { "users" }

    before do
      FakeFS do
        @file_dir = "./spec/queries/jobs/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
        @schema_dir = "./db/"
        FileUtils.mkdir_p(@schema_dir) unless Dir.exist?(@schema_dir)
      end
    end

    it "creates job file" do
      file_path = "#{@file_dir}#{class_name}_spec.rb"
      FakeFS.activate!
      File.open("#{@schema_dir}schema.rb", "w") {}
      a1 = Souls::Generate.new.rspec_job("user")
      file_output = File.read(file_path)

      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(OutputScaffold.scaffold_rspec_job))
    end
  end
end
