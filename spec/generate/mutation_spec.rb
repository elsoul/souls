RSpec.describe(Souls::Api::Generate) do
  describe "Generate Create Mutation" do
    let(:class_name) { "user" }

    before do
      file_dir = "./app/graphql/mutations/base/#{class_name}"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}create_#{class_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "create_mutation_head" do
      file_path = "./app/graphql/mutations/base/#{class_name}/create_#{class_name.singularize}.rb"
      a1 = Souls::Api::Generate.create_mutation_head(class_name: class_name)
      expect(a1).to(eq(file_path))
      FileUtils.rm(file_path)
    end

    it "create_mutation_params" do
      file_path = "./app/graphql/mutations/base/#{class_name}/create_#{class_name.singularize}.rb"
      a1 = Souls::Api::Generate.create_mutation_params(class_name: class_name)
      expect(a1).to(be_all(String))
      FileUtils.rm(file_path)
    end

    it "create_mutation_after_params" do
      relation_params = Souls::Api::Generate.create_mutation_params(class_name: class_name)
      a1 = Souls::Api::Generate.create_mutation_after_params(class_name: class_name, relation_params: relation_params)
      expect(a1).to(be(true))
    end

    it "create_mutation_end" do
      file_path = "./app/graphql/mutations/base/#{class_name}/create_#{class_name.singularize}.rb"
      a1 = Souls::Api::Generate.create_mutation_end(class_name: class_name)
      expect(a1).to(eq(file_path))
    end
  end

  describe "Generate Update Mutation" do
    let(:class_name) { "article" }
    before do
      file_dir = "./app/graphql/mutations/base/#{class_name}"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}update_#{class_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "update_mutation_head" do
      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name.singularize}.rb"
      a1 = Souls::Api::Generate.update_mutation_head(class_name: class_name)
      expect(a1).to(eq(file_path))
      FileUtils.rm(file_path)
    end
    it "update_mutation_params" do
      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name.singularize}.rb"
      a1 = Souls::Api::Generate.update_mutation_params(class_name: class_name)
      expect(a1).to(be_all(String))
      FileUtils.rm(file_path)
    end

    it "update_mutation_after_params" do
      relation_params = Souls::Api::Generate.update_mutation_params(class_name: class_name)
      a1 = Souls::Api::Generate.update_mutation_after_params(class_name: class_name, relation_params: relation_params)
      expect(a1).to(be(true))
    end

    it "update_mutation_end" do
      file_path = "./app/graphql/mutations/base/#{class_name}/update_#{class_name.singularize}.rb"
      a1 = Souls::Api::Generate.update_mutation_end(class_name: class_name)
      expect(a1).to(eq(file_path))
    end
  end
end