require_relative "./output_scaffolds/scaffold_mutation_create"
require_relative "./output_scaffolds/scaffold_mutation_update"
require_relative "./output_scaffolds/scaffold_mutation_delete"
require_relative "./output_scaffolds/scaffold_mutation_destroy_delete"

RSpec.describe(Souls::Generate) do
  describe "Generate Mutation" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./app/graphql/mutations/base/#{class_name}/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    describe "create_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}create_#{class_name.singularize}.rb"

        FakeFS.activate!
        generate = Souls::Generate.new
        allow(Souls).to receive(:get_relation_params).and_return({:params => {}})
        a1 = generate.send(:create_mutation, **{ class_name: class_name})
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(OutputScaffold.scaffold_mutation_create))
      end
    end

    describe "update_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}update_#{class_name.singularize}.rb"

        FakeFS.activate!
        generate = Souls::Generate.new
        allow(Souls).to receive(:get_relation_params).and_return({:params => {}})
        a1 = generate.send(:update_mutation, **{ class_name: class_name})
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(OutputScaffold.scaffold_mutation_update))
      end
    end

    describe "delete_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}delete_#{class_name.singularize}.rb"

        FakeFS.activate!
        generate = Souls::Generate.new
        a1 = generate.send(:delete_mutation, **{ class_name: class_name})
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(OutputScaffold.scaffold_mutation_delete))
      end
    end

    describe "destroy_delete_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}destroy_delete_#{class_name.singularize}.rb"

        FakeFS.activate!
        generate = Souls::Generate.new
        a1 = generate.send(:destroy_delete_mutation, **{ class_name: class_name})
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(OutputScaffold.scaffold_mutation_dd))
      end
    end
  end
end
