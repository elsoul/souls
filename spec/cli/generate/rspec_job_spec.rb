require_relative "./scaffolds/scaffold_rspec_job"

RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Job" do
    let(:class_name) { "user" }
    let(:file_name) { "users" }

    before do
      FakeFS do
        @file_dir = "./spec/queries/jobs/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
        @schema_dir = "./db/"
        FileUtils.mkdir_p(@schema_dir) unless Dir.exist?(@schema_dir)
      end
    end

    it "creates mailer if mailer" do
      cli = Souls::Generate.new
      allow(cli).to(receive(:options).and_return({ mailer: true }))

      file_path = "#{@file_dir}mailer_spec.rb"
      FakeFS.activate!
      cli.rspec_job("mailer")
      file_output = File.read(file_path)

      expect(File.exist?(file_path)).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(Scaffold.scaffold_rspec_job_mailer))
    end

    it "otherwise creates job file" do
      file_path = "#{@file_dir}#{class_name}_spec.rb"
      FakeFS.activate!
      Souls::Generate.new.rspec_job("user")
      file_output = File.read(file_path)

      expect(File.exist?(file_path)).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(Scaffold.scaffold_rspec_job))
    end
  end
end
