require_relative "scaffolds/api_yml_scaffold"
require_relative "scaffolds/env_scaffold"

RSpec.describe(SOULs::Compute) do
  describe "index" do
    describe "setup_vpc_nat" do
      before :each do
        allow($stdout).to(receive(:write))
      end

      it "should call a bunch of methods" do
        cli = SOULs::Compute.new
        allow(cli).to(receive(:create_network).and_return(true))
        allow(cli).to(receive(:create_firewall_tcp).and_return(true))
        allow(cli).to(receive(:create_firewall_ssh).and_return(true))
        allow(cli).to(receive(:create_subnet).and_return(true))
        allow(cli).to(receive(:create_connector).and_return(true))
        allow(cli).to(receive(:create_router).and_return(true))
        allow(cli).to(receive(:create_external_ip).and_return(true))
        allow(cli).to(receive(:create_nat).and_return(true))
        allow(cli).to(receive(:update_workflows).and_return(true))
        allow(cli).to(receive(:update_env).and_return(true))

        allow_any_instance_of(SOULs::Sql).to(receive(:setup_private_ip).and_return(true))
        allow_any_instance_of(SOULs::Gcloud).to(receive(:config_set).and_return(true))

        expect(cli.setup_vpc_nat).to(eq(true))
      end
    end

    describe "update_env" do
      it "should update env file from .env.production" do
        cli = SOULs::Compute.new
        FakeFS.with_fresh do
          allow(SOULs.configuration).to(receive(:instance_name).and_return("abc"))
          allow(SOULs).to(receive(:get_mother_path).and_return("./"))
          allow(cli).to(receive(:`).and_return("111.222.333.44"))
          allow(cli).to(receive(:system).and_return(true))

          File.open(".env.production", "w") { |f| f.write(Scaffold.scaffold_env) }

          cli.__send__(:update_env)
          output = File.read(".env.production")
          expect(output).to(eq(Scaffold.scaffold_env_updated))
        end
      end
    end

    describe "get_external_ip" do
      it "should call compute addresses list" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(cli).to(receive(:`)).and_return("")
        expect(cli).to(receive(:`).with("gcloud compute addresses list | grep test-app-worker-ip | awk '{print $2}'"))
        expect(cli.__send__(:get_external_ip)).to(eq(""))
      end
    end

    describe "create_network" do
      it "should call compute networks" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(receive(:system).with("gcloud compute networks create test-app"))

        expect(cli.__send__(:create_network)).to(eq(true))
      end
    end

    describe "create_firewall_tcp" do
      it "should run firewall-rules create" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(
          receive(:system).with(
            "gcloud compute firewall-rules create test-app \
                  --network test-app --allow tcp,udp,icmp --source-ranges 10-2"
          )
        )

        expect(cli.__send__(:create_firewall_tcp, **{ range: "10-2" })).to(eq(true))
      end
    end

    describe "create_firewall_ssh" do
      it "should run firewall-rules create" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(
          receive(:system).with(
            "gcloud compute firewall-rules create test-app-ssh --network test-app \
            --allow tcp:22,tcp:3389,icmp"
          )
        )

        expect(cli.__send__(:create_firewall_ssh)).to(eq(true))
      end
    end

    describe "create_subnet" do
      it "shouuld call subnets create" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(SOULs.configuration).to(receive(:region).and_return("japan"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(
          receive(:system).with(
            "gcloud compute networks subnets create test-app-subnet \
            --range=10-2 --network=test-app --region=japan"
          )
        )

        expect(cli.__send__(:create_subnet, **{ range: "10-2" })).to(eq(true))
      end
    end

    describe "create_connector" do
      it "should call vpc-access" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(SOULs.configuration).to(receive(:project_id).and_return("123"))
        allow(SOULs.configuration).to(receive(:region).and_return("japan"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(
          receive(:system).with(
            "gcloud compute networks vpc-access connectors create test-app-connector \
              --region=japan \
              --subnet-project=123 \
              --subnet=test-app-subnet"
          )
        )

        expect(cli.__send__(:create_connector)).to(eq(true))
      end
    end

    describe "create_router" do
      it "should call routers create" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(SOULs.configuration).to(receive(:region).and_return("japan"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(
          receive(:system).with(
            "gcloud compute routers create test-app-router --network=test-app --region=japan"
          )
        )

        expect(cli.__send__(:create_router)).to(eq(true))
      end
    end

    describe "create_external_ip" do
      it "should call compute addresses create" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(SOULs.configuration).to(receive(:region).and_return("japan"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(receive(:system).with("gcloud compute addresses create test-app-worker-ip --region=japan"))

        expect(cli.__send__(:create_external_ip)).to(eq(true))
      end
    end

    describe "create_nat" do
      it "should call nats create" do
        cli = SOULs::Compute.new
        allow(SOULs.configuration).to(receive(:app).and_return("test-app"))
        allow(SOULs.configuration).to(receive(:region).and_return("japan"))
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(
          receive(:system).with(
            "gcloud compute routers nats create test-app-worker-nat \
                  --router=test-app-router \
                  --region=japan \
                  --nat-custom-subnet-ip-ranges=test-app-subnet \
                  --nat-external-ip-pool=test-app-worker-ip"
          )
        )

        expect(cli.__send__(:create_nat)).to(eq(true))
      end
    end

    describe "network_list" do
      it "should call networks list" do
        cli = SOULs::Compute.new
        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(receive(:system).with("gcloud compute networks list"))

        expect(cli.__send__(:network_list)).to(eq(true))
      end
    end

    describe "update_workflows" do
      before(:each) do
        allow(SOULs.configuration).to(receive(:app).and_return("app"))
        allow(SOULs).to(receive(:get_mother_path).and_return("./"))
      end

      it "should add connector to api" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(".github/workflows/")
          File.open(".github/workflows/api.yml", "w") { |f| f.write(Scaffold.scaffold_api_yml) }

          cli = SOULs::Compute.new
          cli.__send__(:update_workflows)

          output = File.read(".github/workflows/api.yml")

          expect(output).to(eq(Scaffold.scaffold_api_yml_api))
        end
      end

      it "should add egress to worker" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(".github/workflows/")
          File.open(".github/workflows/worker.yml", "w") { |f| f.write(Scaffold.scaffold_api_yml) }

          cli = SOULs::Compute.new
          cli.__send__(:update_workflows)

          output = File.read(".github/workflows/worker.yml")

          expect(output).to(eq(Scaffold.scaffold_api_yml_worker))
        end
      end

      it "should not add extra lines to file" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(".github/workflows/")
          File.open(".github/workflows/worker.yml", "w") { |f| f.write(Scaffold.scaffold_api_yml_worker) }

          cli = SOULs::Compute.new
          cli.__send__(:update_workflows)

          output = File.read(".github/workflows/worker.yml")

          expect(output).to(eq(Scaffold.scaffold_api_yml_worker))
        end
      end
    end
  end
end
