RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Mutation" do
    let(:class_name) { "user" }
    let(:file_name) { "user_spec" }

    before do
      file_dir = "./spec/mutations/base/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{file_name}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates mutation file" do
      file_dir = "./spec/mutations/base/"
      file_path = "#{file_dir}#{file_name}.rb"
      a1 = Souls::Generate.new.invoke(:rspec_mutation, ["user"], {})
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf("./spec/mutations")
    end
  end
end