require_relative "scaffolds/scaffold_workflows"

RSpec.describe(Souls::Github) do
  describe "index" do
    describe "watch" do
      it "should raise error with no connection to github " do
        cli = Souls::Github.new
        allow(cli).to(receive(:`).and_return("{}"))
        allow(cli).to(receive(:`).with("git remote get-url origin").and_return("abc123"))
        expect(JSON).not_to(receive(:parse))
        expect { cli.watch }
          .to(raise_error(Souls::CLIException))
      end

      it "should raise error with malformed json" do
        cli = Souls::Github.new
        allow(cli).to(receive(:`).and_return("{}"))
        allow(cli).to(receive(:`).with("git remote get-url origin").and_return("git@github.com:elsoul/souls.git"))
        expect(JSON).to(receive(:parse))
        expect { cli.watch }
          .to(raise_error(Souls::CLIException))
      end

      it "should raise error with no workflows" do
        cli = Souls::Github.new
        allow(cli).to(receive(:`).and_return(Scaffold.scaffold_no_workflows))
        allow(cli).to(receive(:`).with("git remote get-url origin").and_return("git@github.com:elsoul/souls.git"))
        expect { cli.watch }
          .to(raise_error(Souls::CLIException))
      end

      it "should call gh run watch with one workflow" do
        cli = Souls::Github.new
        allow(cli).to(receive(:`).and_return(Scaffold.scaffold_one_workflow))
        allow(cli).to(receive(:`).with("git remote get-url origin").and_return("git@github.com:elsoul/souls.git"))

        allow(cli).to(receive(:system).and_return(true))
        expect(cli).to(receive(:system).with("gh run watch 11916875"))

        expect(cli.watch).to(eq(true))
      end

      it "should prompt user with multiple workflows" do
        cli = Souls::Github.new
        allow(cli).to(receive(:`).and_return(Scaffold.scaffold_two_workflows))
        allow(cli).to(receive(:`).with("git remote get-url origin").and_return("git@github.com:elsoul/souls.git"))

        allow(cli).to(receive(:system).and_return(true))
        allow_any_instance_of(TTY::Prompt).to(receive(:select).and_return("11916874"))
        expect(cli).to(receive(:system).with("gh run watch 11916874"))

        expect(cli.watch).to(eq(true))
      end
    end
  end
end
