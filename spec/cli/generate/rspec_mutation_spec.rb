require_relative "./scaffolds/scaffold_rspec_mutation"

RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Mutation" do
    let(:class_name) { "user" }
    let(:file_name) { "user_spec" }

    before do
      FakeFS do
        @file_dir = "./spec/mutations/base/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
        @schema_dir = "./db/"
        FileUtils.mkdir_p(@schema_dir) unless Dir.exist?(@schema_dir)
      end
    end

    it "creates mutation file" do
      file_path = "#{@file_dir}#{file_name}.rb"
      FakeFS.activate!
      FileUtils.touch("#{@schema_dir}schema.rb")
      a1 = Souls::Generate.new.rspec_mutation("user")
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exist?(file_path)).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(Scaffold.scaffold_rspec_mutation))
    end
  end
end
