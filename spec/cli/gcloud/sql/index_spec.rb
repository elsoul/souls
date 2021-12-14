RSpec.describe(Souls::Sql) do
  describe "create_instance" do
    it "should create remote instance" do
      cli = Souls::Sql.new
      allow(cli).to(receive(:options).and_return({ mysql: false }))
      allow_any_instance_of(TTY::Prompt).to(receive(:mask).and_return("abc"))
      allow(cli).to(receive(:system).and_return(true))
      allow(Souls).to(receive(:get_api_path).and_return("./"))
      allow(Souls).to(receive(:get_mother_path).and_return("./"))
      allow_any_instance_of(Souls::Github).to(receive(:secret_set))

      expect(cli.create_instance).to(eq(true))
    end
  end

  describe "list" do
    it "should call system" do
      cli = Souls::Sql.new
      allow(cli).to(receive(:system).and_return(true))
      expect(cli).to(receive(:system).with("gcloud sql instances list"))

      cli.list
    end
  end

  describe "setup_private_ip" do
    it "should call three methods" do
      cli = Souls::Sql.new
      allow(cli).to(receive(:create_ip_range).and_return(true))
      allow(cli).to(receive(:create_vpc_connector).and_return(true))
      allow(cli).to(receive(:assign_network).and_return(true))

      expect(cli).to(receive(:create_ip_range).and_return(true))
      expect(cli).to(receive(:create_vpc_connector).and_return(true))
      expect(cli).to(receive(:assign_network).and_return(true))

      cli.setup_private_ip
    end
  end

  describe "assign_network" do
    it "should call system with correct command" do
      cli = Souls::Sql.new

      allow(cli).to(receive(:system).and_return(true))
      expect(cli).to(
        receive(:system).with(
          "gcloud beta sql instances patch souls-souls-db --project=el-quest --network=souls"
        )
      )

      cli.assign_network
    end
  end

  describe "create_ip_range" do
    it "should call system with correct command" do
      cli = Souls::Sql.new
      allow(cli).to(receive(:system).and_return(true))
      expect(cli).to(
        receive(:system).with(
          "
            gcloud compute addresses create souls-ip-range \
              --global \
              --purpose=VPC_PEERING \
              --prefix-length=16 \
              --description='peering range for SOULs' \
              --network=souls \
              --project=el-quest"
        )
      )

      cli.create_ip_range
    end
  end

  describe "create_vpc_connector with correct command" do
    it "should call system" do
      cli = Souls::Sql.new
      allow(cli).to(receive(:system).and_return(true))
      expect(cli).to(
        receive(:system).with(
          "
          gcloud services vpc-peerings connect \
            --service=servicenetworking.googleapis.com \
            --ranges=souls-ip-range \
            --network=souls \
            --project=el-quest
      "
        )
      )

      cli.create_vpc_connector
    end
  end

  describe "assign_ip" do
    it "should call system with correct command" do
      cli = Souls::Sql.new
      allow(cli).to(receive(:system).and_return(true))
      allow(cli).to(receive(:options).and_return({ ip: "11.11.1" }))
      cloud_sql = { settings: { ipConfiguration: { authorizedNetworks: [{ value: "12.34.5" }] } } }.to_json
      allow(cli).to(receive(:`).and_return(cloud_sql))

      expect(cli).to(
        receive(:system).with(
          "
            gcloud sql instances patch souls-souls-db \
              --project=el-quest \
              --assign-ip \
              --authorized-networks=11.11.1,12.34.5 \
              --quiet
            "
        )
      )

      cli.assign_ip
    end
  end

  describe "region_to_timezone" do
    it "should return asia tokyo with asia" do
      cli = Souls::Sql.new
      result = cli.__send__(:region_to_timezone, **{ region: "asia-northeast" })
      expect(result).to(eq("Asia/Tokyo"))
    end

    it "shouuld return europe amsterdam with europe" do
      cli = Souls::Sql.new
      result = cli.__send__(:region_to_timezone, **{ region: "123-europe" })
      expect(result).to(eq("Europe/Amsterdam"))
    end

    it "shouuld return america la otherwise" do
      cli = Souls::Sql.new
      result = cli.__send__(:region_to_timezone, **{ region: "brazil" })
      expect(result).to(eq("America/Los_Angeles"))
    end
  end
end
