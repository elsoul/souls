RSpec.describe(Souls::Generate) do
  describe "Generate Connection" do
    let(:class_name) { "user" }

    before do
      file_dir = "./app/graphql/types/connections/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates edge.rb file" do
      file_dir = "./app/graphql/types/connections/"
      file_path = "./app/graphql/types/connections/#{class_name.singularize}_connection.rb"
      a1 = Souls::Generate.connection(class_name: class_name)
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    end
  end
end