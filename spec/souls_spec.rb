RSpec.describe Souls do
  it "has a version number" do
    expect(Souls::VERSION).not_to be nil
  end

  describe "Configuration" do
    it "Should be able to set configuration" do
      Souls.configure do |config|
        config.project_id = "elsoul"
        config.app = "elsoul"
        config.network = "elsoul"
        config.machine_type = "elsoul"
        config.zone = "elsoul"
        config.domain = "elsoul"
        config.google_application_credentials = "./config/credentials.json"
        config.strain = "api"
        config.proto_package_name = "souls"
      end

      expect(Souls.configuration.project_id).to eq "elsoul"
    end
  end
end
