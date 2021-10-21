RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Policy" do
    let(:class_name) { "user" }
    let(:file_name) { "user_policy_spec" }

    before do
      file_dir = "./spec/policies/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{file_name}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates mutation file" do
      file_dir = "./spec/policies/"
      file_path = "#{file_dir}#{file_name}.rb"
      a1 = Souls::Generate.new.invoke(:rspec_policy, ["user"], {})
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    rescue StandardError => error
      FileUtils.rm_rf(file_dir) if Dir.exist?(file_dir)
    end
  end
end