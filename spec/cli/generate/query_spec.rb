RSpec.describe(Souls::Generate) do
  describe "Generate Query" do
    let(:class_name) { "user" }
    let(:file_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./app/graphql/queries/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates policy file" do
      file_path = "#{@file_dir}#{file_name.pluralize}.rb"
      FakeFS.activate!
      a1 = Souls::Generate.new.invoke(:query, ["user"], {})
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      example_file_path = File.join(File.dirname(__FILE__), "output_scaffolds/scaffold_query.rb")
      expect(file_output).to(eq(File.read(example_file_path)))
    end
  end
end
