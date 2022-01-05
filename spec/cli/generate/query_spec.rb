require_relative "./scaffolds/scaffold_query"

RSpec.describe(SOULs::Generate) do
  describe "Generate Query" do
    let(:class_name) { "user" }
    let(:file_name) { "user" }

    it "runs methods to create both query files" do
      FakeFS.with_fresh do
        generate = SOULs::Generate.new

        allow(generate).to(receive(:create_individual_query).and_return(""))
        allow(generate).to(receive(:create_index_query).and_return(""))

        expect(generate).to(receive(:create_individual_query))

        generate.query(class_name)
      end
    end

    it "creates single query file" do
      scaffold_output = Scaffold.scaffold_individual_query
      FakeFS.with_fresh do
        file_dir = "./app/graphql/queries/"
        FileUtils.mkdir_p(file_dir)

        file_path = "#{file_dir}#{file_name.singularize}.rb"

        generate = SOULs::Generate.new
        a1 = generate.__send__(:create_individual_query, class_name: "user")
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))
        expect(file_output).to(eq(scaffold_output))
      end
    end
  end
end
