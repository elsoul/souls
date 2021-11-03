require_relative "./scaffolds/scaffold_steepfile"
require_relative "./scaffolds/scaffold_souls"

RSpec.describe(Souls::CLI) do
  describe "worker" do
  end

  describe "steepfile" do
    it "should move Steepfile contents" do
      cli = Souls::Create.new

      FakeFS.activate!
      FileUtils.mkdir_p("config") unless Dir.exist?("config")
      File.open("./Steepfile", 'w') { |file| file.write(Scaffold.scaffold_steepfile) }

      cli.send(:steepfile, "mailer")
      expect(File.exists? "./Steepfile").to(eq(true))
      FakeFS.deactivate!
    end
  end

  describe "procfile" do
    it "should write procfile contents" do
      FakeFS.with_fresh do
        cli = Souls::Create.new
        FileUtils.mkdir_p("apps/mailer") unless Dir.exist?("apps/mailer")

        cli.send(:procfile, "mailer", 123)
        output = File.readlines("apps/mailer/Procfile.dev")
        expected_output = ["mailer: bundle exec puma -p 123 -e development"]
        expect(output).to eq(expected_output)
      end
    end
  end

  describe "mother_procfile" do
    it "should write mother procfile contents" do
      FakeFS.with_fresh do
        cli = Souls::Create.new

        cli.send(:mother_procfile, "mailer")
        output = File.readlines("Procfile.dev")[1]

        expected_output = "mailer: foreman start -f ./apps/mailer/Procfile.dev"
        expect(output).to eq(expected_output)
      end
    end
  end

  describe "souls_conf_update" do
    it "should write souls conf with mother" do
      FakeFS.with_fresh do
        cli = Souls::Create.new
        FileUtils.mkdir_p("config") unless Dir.exist?("config")
        File.open("config/souls.rb", "w") { |file| file.write(Scaffold.scaffold_souls) }

        cli.send(:souls_conf_update, "mailer", "mother")
        output = File.read("config/souls.rb")

        expected_output = Scaffold.scaffold_souls_updated
        expect(output).to eq(expected_output)
      end
    end

    it "should write souls conf to other location without mother" do
      FakeFS.with_fresh do
        cli = Souls::Create.new
        file_dir = "apps/api/config"
        FileUtils.mkdir_p("#{file_dir}") unless Dir.exist?("#{file_dir}")
        File.open("#{file_dir}/souls.rb", "w") { |file| file.write(Scaffold.scaffold_souls) }

        cli.send(:souls_conf_update, "mailer", "father")
        output = File.read("#{file_dir}/souls.rb")

        expected_output = Scaffold.scaffold_souls_updated
        expect(output).to eq(expected_output)
      end
    end
  end

  describe "workflow" do
    
  end

  describe "souls_config_init" do

  end

  describe "souls_helper_rbs" do

  end

  describe "download_worker" do

  end

  describe "souls_worker_credit" do

  end
end
