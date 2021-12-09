require_relative "./scaffolds/scaffold_manager"

RSpec.describe(Souls::Generate) do
  describe "Generate Manager" do
    let(:class_name) { "user" }

    describe "manager" do
      it "calls create manager" do
        cli = Souls::Generate.new

        allow(cli).to(receive(:create_manager).and_return(true))
        allow_any_instance_of(Souls::Generate).to(receive(:invoke).and_return(true))

        expect(cli).to(receive(:create_manager))

        cli.manager(class_name)
      end
    end

    describe "create_manager" do
      before do
        FakeFS do
          @file_dir = "./app/graphql/mutations/managers/"
          FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
        end
      end

      it "creates manager file" do
        file_path = "#{@file_dir}#{class_name.singularize}_manager/#{class_name}.rb"
        FakeFS.activate!
        generate = Souls::Generate.new
        allow(Souls).to(receive(:get_mother_path).and_return(""))
        a1 = generate.__send__(:create_manager, class_name, "user")
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))
        FakeFS.deactivate!

        expect(file_output).to(eq(Scaffold.scaffold_manager))
      end
    end
  end
end
