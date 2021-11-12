require_relative "./scaffolds/scaffold_mutation_create_rbs"
require_relative "./scaffolds/scaffold_mutation_update_rbs"

RSpec.describe(Souls::Update) do
  describe "create_mutation_rbs" do
    it "should modify the rbs file" do
      mutation_create = Scaffold.scaffold_mutation_create_rbs
      FakeFS.with_fresh do
        cli = Souls::Update.new
        file_dir = "./sig/api/app/graphql/mutations/base/user/"
        FileUtils.mkdir_p("#{file_dir}")
        FileUtils.mkdir_p("config")
        FileUtils.mkdir_p("/souls/apps/api")

        File.open("#{file_dir}create_user.rbs", "w") { |f| f.write(mutation_create) }
        allow(Souls).to receive(:get_columns_num).and_return([{ column_name: "test", type: "String", array: false }])

        cli.create_mutation_rbs("user")
        puts "#{file_dir}create_user.rbs"
        output = File.read("#{file_dir}create_user.rbs")

        expected_output = Scaffold.scaffold_mutation_create_rbs_u
        expect(output).to eq(expected_output)
      end
    end
  end

  describe "update_mutation_rbs" do
    it "should modify the rbs file" do
      mutation_create = Scaffold.update_mutation_update_rbs
      FakeFS.with_fresh do
        cli = Souls::Update.new
        file_dir = "./sig/api/app/graphql/mutations/base/user/"
        FileUtils.mkdir_p("#{file_dir}")
        FileUtils.mkdir_p("config")
        FileUtils.mkdir_p("/souls/apps/api")

        File.open("#{file_dir}update_user.rbs", "w") { |f| f.write(mutation_create) }
        allow(Souls).to receive(:get_columns_num).and_return([{ column_name: "test", type: "String", array: false }])

        cli.update_mutation_rbs("user")
        puts "#{file_dir}update_user.rbs"
        output = File.read("#{file_dir}update_user.rbs")

        expected_output = Scaffold.update_mutation_update_rbs_u
        expect(output).to eq(expected_output)
      end
    end
  end
end
