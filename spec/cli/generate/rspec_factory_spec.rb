RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Factory" do

    let(:class_name) { "user" }
    let(:file_name) { "users" }

    before do
      FakeFS do
        @file_dir = "./spec/factories/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
        @schema_dir = "./db/"
        FileUtils.mkdir_p(@schema_dir) unless Dir.exist?(@schema_dir)
      end
    end

    it "creates factory file" do
      file_path = "#{@file_dir}#{file_name}.rb"
      FakeFS.activate!
      File.open("#{@schema_dir}schema.rb", "w") {}
      a1 = Souls::Generate.new.rspec_factory("user")
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      example_file_path = File.join(File.dirname(__FILE__), "output_scaffolds/scaffold_rspec_factory.rb")
      expect(file_output).to(eq(File.read(example_file_path)))
    end
  end
end
