RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Resolver" do
    let(:class_name) { "user" }
    let(:file_name) { "user_search_spec" }

    before do
      FakeFS do
        @file_dir = "./spec/resolvers/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
        @schema_dir = "./db/"
        FileUtils.mkdir_p(@schema_dir) unless Dir.exist?(@schema_dir)
      end
    end

    it "creates resolver file" do
      file_path = "#{@file_dir}#{file_name}.rb"
      FakeFS.activate!
      File.open("#{@schema_dir}schema.rb", "w") {}

      a1 = Souls::Generate.new.rspec_resolver("user")
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      example_file_path = File.join(File.dirname(__FILE__), "output_scaffolds/scaffold_rspec_resolver.rb")
      expect(file_output).to(eq(File.read(example_file_path)))
    end
  end
end
