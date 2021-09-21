RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Model" do
    let(:class_name) { "user" }
    let(:file_name) { "user_spec" }

    before do
      file_dir = "./spec/models/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{file_name}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates model file" do
      file_dir = "./spec/models/"
      file_path = "#{file_dir}#{file_name}.rb"
      a1 = Souls::Generate.new.invoke(:rspec_model, ["user"], {})
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    end
  end
end