require_relative "./scaffolds/scaffold_edge"

RSpec.describe(Souls::Generate) do
  describe "Generate Edge" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./app/graphql/types/edges/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates correct edge.rb file" do
      file_path = "#{@file_dir}#{class_name.singularize}_edge.rb"
      FakeFS.activate!
      a1 = Souls::Generate.new.edge(class_name)
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exist?(file_path)).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(Scaffold.scaffold_edge))
    end
  end
end
