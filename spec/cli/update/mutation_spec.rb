require_relative "./scaffolds/scaffold_mutation_create"
require_relative "./scaffolds/scaffold_mutation_update"

RSpec.describe(SOULs::Update) do
  describe "create_mutation" do
    it "Should update create type from schema" do
      mutation_create = Scaffold.update_mutation_create
      FakeFS.with_fresh do
        cli = SOULs::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p(file_dir.to_s)

        File.open("#{file_dir}create_user.rb", "w") { |f| f.write(mutation_create) }
        allow(SOULs).to(receive(:get_columns_num).and_return([{ column_name: "test", type: "String", array: false }]))

        cli.create_mutation("user")
        puts "#{file_dir}create_user.rb"
        output = File.read("#{file_dir}create_user.rb")

        expected_output = Scaffold.update_mutation_create_u
        expect(output).to(eq(expected_output))
      end
    end

    it "Should work even if 'argument' is somewhere else" do
      mutation_create = Scaffold.update_mutation_create_arg
      FakeFS.with_fresh do
        cli = SOULs::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p(file_dir.to_s)

        File.open("#{file_dir}create_user.rb", "w") { |f| f.write(mutation_create) }
        allow(SOULs).to(receive(:get_columns_num).and_return([{ column_name: "test", type: "String", array: false }]))

        cli.create_mutation("user")
        puts "#{file_dir}create_user.rb"
        output = File.read("#{file_dir}create_user.rb")

        expected_output = Scaffold.update_mutation_arg_u
        expect(output).to(eq(expected_output))
      end
    end

    it "Should fail with CLIException if there's no file" do
      FakeFS.with_fresh do
        cli = SOULs::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p(file_dir.to_s)
        allow(SOULs).to(receive(:get_columns_num).and_return(2))

        expect(SOULs::Painter).to(receive(:error))
        expect(cli.update_mutation("user")).to(eq(nil))
      end
    end
  end

  describe "update_mutation" do
    it "should update the update type from schema" do
      mutation_create = Scaffold.update_mutation_update
      FakeFS.with_fresh do
        cli = SOULs::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p(file_dir.to_s)
        FileUtils.mkdir_p("tmp")

        File.open("#{file_dir}update_user.rb", "w") { |f| f.write(mutation_create) }
        allow(SOULs).to(receive(:get_columns_num).and_return([{ column_name: "test", type: "String", array: false }]))

        cli.update_mutation("user")
        puts "#{file_dir}update_user.rb"
        output = File.read("#{file_dir}update_user.rb")

        expected_output = Scaffold.update_mutation_update_u
        expect(output).to(eq(expected_output))
      end
    end

    it "Should fail with CLIException if there's no file" do
      FakeFS.with_fresh do
        cli = SOULs::Update.new
        file_dir = "./app/graphql/mutations/base/user/"
        FileUtils.mkdir_p(file_dir.to_s)
        allow(SOULs).to(receive(:get_columns_num).and_return(2))

        expect(SOULs::Painter).to(receive(:error))
        expect(cli.update_mutation("user")).to(eq(nil))
      end
    end
  end
end
