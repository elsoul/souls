RSpec.describe(Souls::Generate) do
  describe "Generate Scaffold" do
    def clear_crud_files
      file_paths = [
        "./app",
        "./spec/factories",
        "./spec/models",
        "./spec/mutations",
        "./spec/queries",
        "./spec/resolvers",
        "./spec/policies"
      ]
      file_paths.each { |path| FileUtils.rm_rf(path) if Dir.exist?(path) }
    end
    it "creates CRUD files from schema.rb" do
      a1 = Souls::Generate.new.invoke(:scaffold, ["user"], {})
      expect(a1).to(eq(true))
      clear_crud_files
    end

    it "creates All CRUD files from schema.rb" do
      a1 = Souls::Generate.new.invoke(:scaffold_all, [], {})
      expect(a1).to(eq(true))
      clear_crud_files
    end
  end
end