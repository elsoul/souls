RSpec.describe Souls::Generate do
  describe "Generate Edge" do
    let(:class_name) { "user" }

    before do
      file_dir = "./app/graphql/types/edges/"
      FileUtils.mkdir_p file_dir unless Dir.exist? file_dir
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      FileUtils.rm file_path if File.exist? file_path
    end

    it "creates edge.rb file" do
      file_path = "./app/graphql/types/edges/#{class_name.singularize}_edge.rb"
      a1 = Souls::Generate.edge class_name: class_name
      expect(a1).to eq file_path
      FileUtils.rm file_path
    end
  end
end
