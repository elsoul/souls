require_relative "./scaffolds/scaffold_job"

RSpec.describe(Souls::Generate) do
  let(:class_name) { "some_job" }

  describe "job" do
    it "calls mailer if mailer" do
      cli = Souls::Generate.new

      allow_any_instance_of(Souls::Generate).to(receive(:invoke).and_return(true))
      allow(cli).to(receive(:options).and_return({ mailer: true }))

      allow(cli).to(receive(:create_job_mailer_type).and_return(true))
      allow(cli).to(receive(:mailgun_mailer).and_return(true))

      expect(cli).to(receive(:create_job_mailer_type).and_return(true))
      expect(cli).to(receive(:mailgun_mailer).and_return(true))

      cli.job("abc")
    end

    it "calls create job if not mailer" do
      cli = Souls::Generate.new

      allow_any_instance_of(Souls::Generate).to(receive(:invoke).and_return(true))
      allow(cli).to(receive(:options).and_return({}))

      allow(cli).to(receive(:create_job_type).and_return(true))
      allow(cli).to(receive(:create_job).and_return(true))

      expect(cli).to(receive(:create_job_type).and_return(true))
      expect(cli).to(receive(:create_job).and_return(true))

      cli.job("abc")
    end
  end

  describe "create_job" do
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
  end

  describe "create_job_type" do
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
  end

  describe "mailgun_mailer" do
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
  end

  describe "create_job_mailer_type" do
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
