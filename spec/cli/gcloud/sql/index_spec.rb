RSpec.describe(Souls::Sql) do
  describe "create_instance" do
    it "should create remote instance" do
      cli = Souls::Sql.new
      allow(cli).to(receive(:options).and_return({ mysql: false }))
      allow_any_instance_of(TTY::Prompt).to(receive(:mask).and_return("abc"))
      allow(cli).to(receive(:system).and_return(true))
      allow(Souls).to(receive(:get_api_path).and_return("./"))
      allow(Souls).to(receive(:get_mother_path).and_return("./"))

      expect(cli.create_instance).to(be_kind_of(Souls::Github))
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
    end
  end

  describe "region_to_timezone" do
  end
end
