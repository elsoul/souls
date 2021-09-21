RSpec.describe(Souls::Generate) do
  describe "Generate Create Mutation" do
    let(:class_name) { "user" }

    before do
      file_dir = "./app/graphql/mutations/base/#{class_name}/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}create_#{class_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "create_mutation" do
      file_dir = "./app/graphql/mutations/base/#{class_name}/"
      file_path = "#{file_dir}create_#{class_name.singularize}.rb"
      a1 = Souls::Generate.new.mutation(class_name)
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    end
  end
end