RSpec.describe(Souls::Generate) do
  describe "Generate Resolver" do
    let(:class_name) { "user" }
    let(:file_name) { "user_search" }

    before do
      file_dir = "./app/graphql/resolvers/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{file_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates resolver file" do
      file_dir = "./app/graphql/resolvers/"
      file_path = "#{file_dir}#{file_name.singularize}.rb"
      a1 = Souls::Generate.new.invoke(:resolver, ["user"], {})
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    rescue StandardError => error
      FileUtils.rm(file_path) if File.exist?(file_path)
    end
  end
end