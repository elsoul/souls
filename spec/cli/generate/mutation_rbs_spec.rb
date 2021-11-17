require_relative "./scaffolds/scaffold_mutation_create_rbs"
require_relative "./scaffolds/scaffold_mutation_update_rbs"
require_relative "./scaffolds/scaffold_mutation_delete_rbs"
require_relative "./scaffolds/scaffold_mutation_destroy_delete_rbs"

RSpec.describe(Souls::Generate) do
  describe "Generate Mutation" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./sig/api/app/graphql/mutations/base/#{class_name}/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    describe "create_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}create_#{class_name.singularize}.rbs"

        FakeFS.activate!
        generate = Souls::Generate.new
        allow(Souls).to(receive(:get_relation_params).and_return({ params: {} }))
        allow(Souls).to(receive(:get_mother_path).and_return(""))
        a1 = generate.__send__(:create_rbs_mutation, **{ class_name: class_name })
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(Scaffold.scaffold_mutation_create_rbs))
      end
    end

    describe "update_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}update_#{class_name.singularize}.rbs"

        FakeFS.activate!
        generate = Souls::Generate.new
        allow(Souls).to(
          receive(:get_relation_params).and_return(
            {
              params: [
                {
                  column_name: "website",
                  type: "string",
                  array: false
                }
              ]
            }
          )
        )
        allow(Souls).to(receive(:get_mother_path).and_return(""))
        a1 = generate.__send__(:update_rbs_mutation, **{ class_name: class_name })
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(Scaffold.scaffold_mutation_update_rbs))
      end
    end

    describe "delete_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}delete_#{class_name.singularize}.rbs"

        FakeFS.activate!
        generate = Souls::Generate.new
        allow(Souls).to(receive(:get_mother_path).and_return(""))
        a1 = generate.__send__(:delete_rbs_mutation, **{ class_name: class_name })
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(Scaffold.scaffold_mutation_delete_rbs))
      end
    end

    describe "destroy_delete_mutation" do
      it "generates the correct file" do
        file_path = "#{@file_dir}destroy_delete_#{class_name.singularize}.rbs"

        FakeFS.activate!
        generate = Souls::Generate.new
        allow(Souls).to(receive(:get_mother_path).and_return(""))
        a1 = generate.__send__(:destroy_delete_rbs_mutation, **{ class_name: class_name })
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(Scaffold.scaffold_mutation_dd_rbs))
      end
    end
  end
end
