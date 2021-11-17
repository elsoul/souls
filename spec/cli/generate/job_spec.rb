require_relative "./scaffolds/scaffold_job"

RSpec.describe(Souls::Generate) do
  describe "Generate Job" do
    let(:class_name) { "some_job" }

    it "creates job file" do
      file_scaffold = Scaffold.scaffold_job

      FakeFS.with_fresh do
        query_dir = "./app/graphql/queries/"
        FileUtils.mkdir_p(query_dir)

        file_path = "#{query_dir}#{class_name.singularize}.rb"

        generate = Souls::Generate.new
        a1 = generate.__send__(:create_job, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end

    it "creates type file" do
      file_scaffold = Scaffold.scaffold_job_type

      FakeFS.with_fresh do
        type_dir = "./app/graphql/types/"
        FileUtils.mkdir_p(type_dir)

        file_path = "#{type_dir}#{class_name.singularize}_type.rb"

        generate = Souls::Generate.new
        a1 = generate.__send__(:create_job_type, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end

    it "creates mailer with correct argument" do
      file_scaffold = Scaffold.scaffold_job_mailer

      FakeFS.with_fresh do
        query_dir = "./app/graphql/queries/"
        FileUtils.mkdir_p(query_dir)

        file_path = "#{query_dir}#{class_name.singularize}.rb"

        generate = Souls::Generate.new
        a1 = generate.__send__(:mailgun_mailer, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end

    it "creates mailer type file" do
      file_scaffold = Scaffold.scaffold_job_mailer_type

      FakeFS.with_fresh do
        type_dir = "./app/graphql/types/"
        FileUtils.mkdir_p(type_dir)

        file_path = "#{type_dir}#{class_name.singularize}_type.rb"

        generate = Souls::Generate.new
        allow(Souls).to(receive(:get_mother_path).and_return(""))
        a1 = generate.__send__(:create_job_mailer_type, class_name)
        file_output = File.read(file_path)

        expect(a1).to(eq(file_path))
        expect(File.exist?(file_path)).to(eq(true))

        expect(file_output).to(eq(file_scaffold))
      end
    end
  end
end
