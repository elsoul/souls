require_relative "./scaffolds/scaffold_souls"
require_relative "./scaffolds/scaffold_workflow"
require_relative "./scaffolds/scaffold_souls_helper"

RSpec.describe(SOULs::CLI) do
  describe "worker" do
    before :each do
      allow(SOULs).to(receive(:get_mother_path).and_return("./"))
    end

    it "should raise error if same worker exists" do
      cli = SOULs::Create.new
      allow(Dir).to(receive(:exist?).and_return(true))
      cli_result =
        expect do
          cli.worker
        end

      cli_result.to(raise_error(StandardError))
    end

    it "should call all the private methods and return true" do
      cli = SOULs::Create.new
      FakeFS.with_fresh do
        allow(cli).to(receive(:download_worker).and_return(true))
        allow(cli).to(receive(:souls_conf_update).and_return(true))
        allow(cli).to(receive(:souls_conf_update).and_return(true))
        allow(cli).to(receive(:workflow).and_return(true))
        allow(cli).to(receive(:procfile).and_return(true))
        allow(cli).to(receive(:mother_procfile).and_return(true))
        allow(cli).to(receive(:souls_config_init).and_return(true))
        allow(cli).to(receive(:system).and_return(true))
        allow(cli).to(receive(:souls_worker_credit).and_return(true))

        expect(cli.worker("mailer")).to(eq(true))
      end
    end
  end

  describe "procfile" do
    it "should write procfile contents" do
      FakeFS.with_fresh do
        cli = SOULs::Create.new
        FileUtils.mkdir_p("apps/worker-mailer") unless Dir.exist?("apps/worker-mailer")

        cli.__send__(:procfile, **{ worker_name: "worker-mailer", port: "123" })
        output = File.readlines("apps/worker-mailer/Procfile.dev")
        expected_output = ["worker-mailer: bundle exec puma -p 123 -e development"]
        expect(output).to(eq(expected_output))
      end
    end
  end

  describe "mother_procfile" do
    it "should write mother procfile contents" do
      FakeFS.with_fresh do
        cli = SOULs::Create.new

        cli.__send__(:mother_procfile, **{ worker_name: "worker-mailer" })
        output = File.readlines("Procfile.dev")[1]

        expected_output = "worker-mailer: foreman start -f ./apps/worker-mailer/Procfile.dev"
        expect(output).to(eq(expected_output))
      end
    end
  end

  describe "souls_conf_update" do
    it "should write souls conf with mother" do
      FakeFS.with_fresh do
        cli = SOULs::Create.new
        FileUtils.mkdir_p("config") unless Dir.exist?("config")
        File.open("config/souls.rb", "w") { |file| file.write(Scaffold.scaffold_souls) }

        cli.__send__(:souls_conf_update, **{ worker_name: "worker-mailer", strain: "mother" })
        output = File.read("config/souls.rb")

        expected_output = Scaffold.scaffold_souls_updated
        expect(output).to(eq(expected_output))
      end
    end

    it "should write souls conf to other location without mother" do
      FakeFS.with_fresh do
        cli = SOULs::Create.new
        file_dir = "apps/api/config"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        File.open("#{file_dir}/souls.rb", "w") { |file| file.write(Scaffold.scaffold_souls) }

        cli.__send__(:souls_conf_update, **{ worker_name: "worker-mailer", strain: "father" })
        output = File.read("#{file_dir}/souls.rb")

        expected_output = Scaffold.scaffold_souls_updated
        expect(output).to(eq(expected_output))
      end
    end
  end

  describe "workflow" do
    it "should write workflows" do
      FakeFS.with_fresh do
        cli = SOULs::Create.new
        file_dir = ".github/workflows"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)

        cli.__send__(:workflow, **{ worker_name: "worker-mailer" })
        output = File.read("#{file_dir}/worker-mailer.yml")

        expected_output = Scaffold.scaffold_workflow

        expect(output).to(eq(expected_output))
      end
    end
  end

  describe "souls_config_init" do
    it "should write config file" do
      FakeFS.with_fresh do
        cli = SOULs::Create.new
        file_dir = "apps/worker-mailer/config"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)

        cli.__send__(:souls_config_init, **{ worker_name: "worker-mailer" })
        output = File.read("#{file_dir}/souls.rb")

        expected_output = Scaffold.scaffold_souls_init

        expect(output).to(eq(expected_output))
      end
    end
  end

  describe "download_worker" do
    it "should call system with correct url" do
      cli = SOULs::Create.new
      allow(cli).to(receive(:system).and_return(true))
      allow(SOULs).to(receive(:get_latest_version_txt).and_return(%w[1 5]))

      expect(cli.__send__(:download_worker)).to(eq(["worker-v1.5.tgz"]))
    end
  end

  describe "souls_worker_credit" do
    before :each do
      allow($stdout).to(receive(:write))
    end

    it "should print a bunch of text" do
      cli = SOULs::Create.new
      expect(cli.__send__(:souls_worker_credit)).to(eq(nil))
    end
  end
end
