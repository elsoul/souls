require_relative "./scaffolds/scaffold_connection_rbs"

RSpec.describe(Souls::Generate) do
  describe "Generate Connection RBS" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./sig/api/app/graphql/types/connections/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates connection.rbs file" do
      file_path = "#{@file_dir}#{class_name.singularize}_connection.rbs"
      FakeFS.activate!
      allow(Souls).to receive(:get_mother_path).and_return("")
      a1 = Souls::Generate.new.connection_rbs(class_name)
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(Scaffold.scaffold_connection_rbs))
    end
  end
end
