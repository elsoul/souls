RSpec.describe(Souls::Generate) do
  describe "Generate Connection" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./app/graphql/types/connections/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates edge.rb file" do
      file_path = "#{@file_dir}#{class_name.singularize}_connection.rb"
      FakeFS.activate!
      a1 = Souls::Generate.new.connection(class_name)
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      example_file_path = File.join(File.dirname(__FILE__), "output_scaffolds/scaffold_connection.rb")
      expect(file_output).to(eq(File.read(example_file_path)))
    end
  end
end
