require_relative "./output_scaffolds/scaffold_job"

RSpec.describe(Souls::Generate) do
  describe "Generate Manager" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./app/graphql/mutations/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates job file" do
      file_path = "#{@file_dir}#{class_name.singularize}.rb"
      FakeFS.activate!
      generate = Souls::Generate.new
      allow(Souls).to receive(:get_mother_path).and_return("")
      a1 = generate.send(:create_job_mutation, class_name)
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(OutputScaffold.scaffold_job))
    end
  end
end
