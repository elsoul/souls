require_relative "./output_scaffolds/scaffold_manager"

RSpec.describe(Souls::Generate) do
  describe "Generate Manager" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./app/graphql/mutations/managers/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates manager file" do
      file_path = "#{@file_dir}#{class_name.singularize}_manager/#{class_name}.rb"
      FakeFS.activate!


      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(OutputScaffold.scaffold_manager))
    end
  end
end
