RSpec.describe(Souls::Generate) do
  describe "Generate Model" do
    let(:class_name) { "user" }

    before do
      file_dir = "./app/models/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      FileUtils.rm(file_path) if File.exist?(file_path)
    end

    it "creates model.rb file" do
      file_dir = "./app/models/"
      file_path = "./app/models/#{class_name.singularize}.rb"
      a1 = Souls::Generate.new.model(class_name)
      expect(a1).to(eq(file_path))
      FileUtils.rm_rf(file_dir)
    end
  end
end