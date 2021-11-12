require_relative "./scaffolds/scaffold_job"

RSpec.describe(Souls::Generate) do
  describe "Generate Job" do
    let(:class_name) { "some_job" }

    it "creates job file" do
      file_scaffold = OutputScaffold.scaffold_job

      FakeFS.with_fresh do
        query_dir = "./app/graphql/queries/"
        FileUtils.mkdir_p(query_dir)

        file_path = "#{query_dir}#{class_name.singularize}.rb"

        generate = Souls::Generate.new
        a1 = generate.send(:create_job, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end

    it "creates type file" do
      file_scaffold = OutputScaffold.scaffold_job_type

      FakeFS.with_fresh do
        type_dir = "./app/graphql/types/"
        FileUtils.mkdir_p(type_dir)

          file_path = "#{type_dir}#{class_name.singularize}_type.rb"

        generate = Souls::Generate.new
        a1 = generate.send(:create_job_type, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end

    it "creates mailer with correct argument" do
      file_scaffold = OutputScaffold.scaffold_job_mailer

      FakeFS.with_fresh do
        query_dir = "./app/graphql/queries/"
        FileUtils.mkdir_p(query_dir)

        file_path = "#{query_dir}#{class_name.singularize}.rb"

        generate = Souls::Generate.new
        a1 = generate.send(:mailgun_mailer, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end

    it "creates mailer type file" do
      file_scaffold = OutputScaffold.scaffold_job_mailer_type

      FakeFS.with_fresh do
        type_dir = "./app/graphql/types/"
        FileUtils.mkdir_p(type_dir)

        file_path = "#{type_dir}#{class_name.singularize}_type.rb"

        generate = Souls::Generate.new
        allow(Souls).to receive(:get_mother_path).and_return("")
        a1 = generate.send(:create_job_mailer_type, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end

    it "adds appropriate routes" do
      base_query_type = OutputScaffold.base_query_type
      modified_query_type = OutputScaffold.modified_query_type

      FakeFS.with_fresh do
        type_dir = "./app/graphql/types/base/"
        FileUtils.mkdir_p(type_dir)

        file_path = "#{type_dir}query_type.rb"
        File.open(file_path, "w") { |f| f.write(base_query_type) }
        expect(File.read(file_path)).to(eq(base_query_type))

        generate = Souls::Generate.new
        a1 = generate.send(:update_query_type, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exists? file_path).to(eq(true))

        expect(file_output).to(eq(modified_query_type))
      end
    end
  end
end
