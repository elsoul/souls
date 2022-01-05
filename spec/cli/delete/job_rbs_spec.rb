require_relative "./scaffolds/scaffold_delete"

RSpec.describe(SOULs::Delete) do
  describe "job_rbs" do
    it "should delete file" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        FileUtils.mkdir_p("./apps/mailer")
        Dir.chdir("./apps/mailer") do
          allow(SOULs).to(receive(:get_mother_path).and_return("./"))
          allow(FileUtils).to(receive(:pwd).and_return("./apps/mailer"))
          file_dir = "./sig/mailer/app/graphql/queries/"
          file_name = "#{file_dir}user.rbs"
          FileUtils.mkdir_p(file_dir)
          File.open(file_name, "w") { |f| f.write(Scaffold.scaffold_delete) }

          expect(File.exist?(file_name)).to(be(true))
          cli.job_rbs("user")
          expect(File.exist?(file_name)).to(be(false))
        end
      end
    end

    it "should not error if directory doesn't exist" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        FileUtils.mkdir_p("./apps/mailer")
        Dir.chdir("./apps/mailer") do
          allow(SOULs).to(receive(:get_mother_path).and_return("./"))
          allow(FileUtils).to(receive(:pwd).and_return("./apps/mailer"))
          file_dir = "./sig/mailer/app/graphql/queries/"
          file_name = "#{file_dir}user.rbs"

          expect(File.exist?(file_name)).to(be(false))
          cli.job_rbs("user")
          expect(File.exist?(file_name)).to(be(false))
        end
      end
    end

    it "should warn and exit if directory is not a worker" do
      FakeFS.with_fresh do
        cli = SOULs::Delete.new

        FileUtils.mkdir_p("./abc/def")
        Dir.chdir("./abc/def") do
          allow(SOULs).to(receive(:get_mother_path).and_return("./"))
          allow(FileUtils).to(receive(:pwd).and_return("./abc/def"))

          expect { cli.job_rbs("user") }
            .to(raise_error(SOULs::CLIException))
        end
      end
    end
  end
end
