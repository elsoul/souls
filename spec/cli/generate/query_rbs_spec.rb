require_relative "./scaffolds/scaffold_query_rbs"

RSpec.describe(Souls::Generate) do
  describe "Generate Query RBS" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./sig/api/app/graphql/queries/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates query.rbs file" do
      file_path = "#{@file_dir}#{class_name.singularize}.rbs"
      FakeFS.activate!
      generate = Souls::Generate.new
      generate.options = {mutation: class_name}
      allow(Souls).to receive(:get_mother_path).and_return("")
      allow(FileUtils).to receive(:pwd).and_return("api")
      generate.query_rbs(class_name)
      file_output = File.read(file_path)

      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(OutputScaffold.scaffold_query_rbs))
    end
  end
end
