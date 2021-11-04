require_relative "./scaffolds/scaffold_mutation"

RSpec.describe(Souls::Update) do
  describe "create_mutation" do
    it "Should update GraphQL type from schema" do
      mutation_create = Scaffold.scaffold_mutation_create
      FakeFS.with_fresh do
        cli = Souls::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p("#{file_dir}")

        File.open("#{file_dir}create_user.rb", "w") { |f| f.write(mutation_create) }
        allow(Souls).to receive(:get_columns_num).and_return([{ column_name: "test", type: "String", array: false }])

        cli.create_mutation("user")
        puts "#{file_dir}create_user.rb"
        output = File.read("#{file_dir}create_user.rb")

        expected_output = Scaffold.scaffold_mutation_create_u
        expect(output).to eq(expected_output)
      end
    end

    it "Should work even if 'argument' is somewhere else" do
      mutation_create = Scaffold.scaffold_mutation_create_arg
      FakeFS.with_fresh do
        cli = Souls::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p("#{file_dir}")

        File.open("#{file_dir}create_user.rb", "w") { |f| f.write(mutation_create) }
        allow(Souls).to receive(:get_columns_num).and_return([{ column_name: "test", type: "String", array: false }])

        cli.create_mutation("user")
        puts "#{file_dir}create_user.rb"
        output = File.read("#{file_dir}create_user.rb")

        expected_output = Scaffold.scaffold_mutation_arg_u
        expect(output).to eq(expected_output)
      end
    end

    it "Should fail with CLIException if there's no file" do
      FakeFS.with_fresh do
        cli = Souls::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p("#{file_dir}")
        allow(Souls).to receive(:get_columns_num).and_return(2)

        expect {
          cli.create_mutation("user")
        }.to raise_error(Souls::CLIException)
      end
    end
  end
end
