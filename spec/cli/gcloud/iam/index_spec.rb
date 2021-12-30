RSpec.describe(Souls::Iam) do
  describe "setup_key" do
    before :each do
      allow_any_instance_of(Souls::Upgrade).to(receive(:config).and_return(true))
      allow($stdout).to(receive(:write))
    end

    it "should call a bunch of methods" do
      cli = Souls::Iam.new
      allow(cli).to(receive(:create_service_account).and_return(true))
      allow(cli).to(receive(:create_service_account_key).and_return(true))
      allow(cli).to(receive(:add_permissions).and_return(true))
      allow(cli).to(receive(:set_gh_secret_json).and_return(true))
      allow(cli).to(receive(:system).and_return(true))

      allow_any_instance_of(Souls::Gcloud).to(receive(:auth_login).and_return(true))
      allow_any_instance_of(Souls::Gcloud).to(receive(:enable_permissions).and_return(true))

      expect(cli.setup_key).to(eq(true))
      expect(cli).not_to(receive(:export_key_to_console))
    end

    it "should rescue standarderror if set_gh_secret throws error" do
      cli = Souls::Iam.new
      allow(cli).to(receive(:create_service_account).and_return(true))
      allow(cli).to(receive(:create_service_account_key).and_return(true))
      allow(cli).to(receive(:add_permissions).and_return(true))
      allow(cli).to(receive(:system).and_return(true))

      allow_any_instance_of(Souls::Gcloud).to(receive(:auth_login).and_return(true))
      allow_any_instance_of(Souls::Gcloud).to(receive(:set_gh_secret_json).and_raise(StandardError.new))
      allow_any_instance_of(Souls::Gcloud).to(receive(:enable_permissions).and_return(true))
      allow(cli).to(receive(:export_key_to_console).and_return(true))

      expect(cli).to(receive(:export_key_to_console))
      expect(cli.setup_key).to(eq(true))
    end
  end

  describe "create_service_account" do
    it "should call gcloud" do
      cli = Souls::Iam.new
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(
        receive(:system).with(
          "gcloud iam service-accounts create souls \
          --description='Souls Service Account' \
          --display-name=souls"
        )
      )
      cli.__send__(:create_service_account)
    end
  end

  describe "create_service_account_key" do
    it "should call gcloud" do
      cli = Souls::Iam.new
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(
        receive(:system).with(
          "gcloud iam service-accounts keys create ./config/keyfile.json \
            --iam-account souls@el-quest.iam.gserviceaccount.com"
        )
      )
      cli.__send__(:create_service_account_key)
    end
  end

  describe "export_key_to_console" do
    before :each do
      allow($stdout).to(receive(:write))
    end

    it "should handle keyfile" do
      cli = Souls::Iam.new
      FakeFS.with_fresh do
        FileUtils.mkdir_p("config")
        FileUtils.touch("config/keyfile.json")

        allow(cli).to(receive(:`).and_return("https://github.com/elsoul/souls"))
        expect(cli.__send__(:export_key_to_console)).to(eq(["config/keyfile.json"]))
      end
    end
  end

  describe "add_service_account_role" do
    it "should call gcloud" do
      cli = Souls::Iam.new
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(
        receive(:system).with(
          "gcloud projects add-iam-policy-binding el-quest \
          --member='serviceAccount:souls@el-quest.iam.gserviceaccount.com' \
          --role=roles/firebase.admin"
        )
      )
      cli.__send__(:add_service_account_role)
    end
  end

  describe "add_permissions" do
    it "should add 12 permissions" do
      cli = Souls::Iam.new
      allow(cli).to(receive(:add_service_account_role).and_return(true))

      expect(cli).to(receive(:add_service_account_role).exactly(12).times)
      cli.__send__(:add_permissions)
    end
  end

  describe "set_gh_secret_json" do
    it "should call system and remove file" do
      cli = Souls::Iam.new
      FakeFS.with_fresh do
        FileUtils.mkdir_p("config")
        FileUtils.touch("config/keyfile.json")

        allow(cli).to(receive(:system).and_return(true))
      end
    end
  end
end
