RSpec.describe(Souls::Generate) do
  describe "Generate Rspec Query" do
    let(:class_name) { "user" }
    let(:file_name) { "user_spec" }

    before do
      file_dir = "./spec/queries/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{file_name}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates query file" do
      file_dir = "./spec/queries/"
      file_path = "#{file_dir}#{file_name}.rb"
      a1 = Souls::Generate.new.invoke(:rspec_query, ["user"], {})
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    rescue StandardError => error
      FileUtils.rm_rf(file_dir) if Dir.exist?(file_dir)
    end
  end
end