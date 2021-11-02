require_relative "./output_scaffolds/scaffold_policy"

RSpec.describe(Souls::Generate) do
  describe "Generate Policy" do
    let(:class_name) { "user" }
    let(:file_name) { "user_policy" }

    before do
      FakeFS do
        @file_dir = "./app/policies/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates policy file" do
      file_path = "#{@file_dir}#{file_name.singularize}.rb"
      FakeFS.activate!
      a1 = Souls::Generate.new.policy("user")
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(OutputScaffold.scaffold_policy))
    end
  end
end
