require_relative "./scaffolds/scaffold_rspec_query"

RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Query" do
    let(:class_name) { "user" }
    let(:file_name) { "user_spec" }

    before do
      FakeFS do
        @file_dir = "./spec/queries/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
        @schema_dir = "./db/"
        FileUtils.mkdir_p(@schema_dir) unless Dir.exist?(@schema_dir)
      end
    end

    it "creates query file" do
      file_path = "#{@file_dir}#{file_name}.rb"
      FakeFS.activate!
      File.open("#{@schema_dir}schema.rb", "w") {}

      a1 = Souls::Generate.new.rspec_query("user")
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(Scaffold.scaffold_rspec_query))
    end
  end
end
