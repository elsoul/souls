RSpec.describe(Souls::Create) do
  describe "souls create worker" do
    it "create souls worker" do
      mother_conf = "config/souls.rb"
      mother_tmp = "tmp/souls.rb"
      FileUtils.cp mother_conf, mother_tmp
      FileUtils.cp "apps/api/#{mother_conf}", "tmp/souls-api.rb"
      FileUtils.cp "Procfile.dev", "tmp/Procfile.dev"
      a1 = Souls::Create.new.invoke(:worker, [], {name: "scraper"})
      expect(a1).to(eq(true))
      FileUtils.mv mother_tmp, mother_conf
      FileUtils.mv "tmp/souls-api.rb", "apps/api/#{mother_conf}"
      FileUtils.mv "tmp/Procfile.dev", "Procfile.dev"
      FileUtils.rm_rf "apps/scraper"
      FileUtils.rm_rf ".github/workflows/scraper.yml"
    end
  end
end