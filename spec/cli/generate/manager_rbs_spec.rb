require_relative "./output_scaffolds/scaffold_manager_rbs"

RSpec.describe(Souls::Generate) do
  describe "Generate Manager RBS" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./sig/api/app/graphql/mutations/managers/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates manager.rbs file" do
      file_path = "#{@file_dir}#{class_name.singularize}_manager/#{class_name}.rbs"
      FakeFS.activate!
      generate = Souls::Generate.new
      generate.options = {mutation: class_name}
      allow(Souls).to receive(:get_mother_path).and_return("")
      allow(FileUtils).to receive(:pwd).and_return("api")
      a1 = generate.manager_rbs(class_name)
      file_output = File.read(file_path)
      puts file_output

      expect(a1).to(eq(file_path))
      expect(File.exists? file_path).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(OutputScaffold.scaffold_manager_rbs))
    end
  end
end
