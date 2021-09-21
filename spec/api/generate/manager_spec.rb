RSpec.describe(Souls::Generate) do
  describe "Generate Manager" do
    let(:class_name) { "user" }
    let(:file_name) { "user_login" }

    before do
      file_dir = "./app/graphql/mutations/managers/#{class_name}_manager/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{file_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates manager file" do
      file_dir = "./app/graphql/mutations/managers/#{class_name}_manager/"
      file_path = "#{file_dir}#{file_name.singularize}.rb"
      a1 = Souls::Generate.new.invoke(:manager, ["user"], {mutation: "user_login"})
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    end
  end
end