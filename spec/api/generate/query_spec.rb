RSpec.describe(Souls::Generate) do
  describe "Generate Query" do
    let(:class_name) { "user" }
    let(:file_name) { "user" }

    before do
      file_dir = "./app/graphql/queries/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{file_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates policy file" do
      file_dir = "./app/graphql/queries/"
      file_path = "#{file_dir}#{file_name.pluralize}.rb"
      a1 = Souls::Generate.new.invoke(:query, ["user"], {})
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    end
  end
end