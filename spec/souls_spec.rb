RSpec.describe Souls do
  it "has a version number" do
    expect(Souls::VERSION).not_to be nil
  end

  describe "Configuration" do
    it "Should be able to set configuration" do
      Souls.configure do |config|
        config.strain = "api"
      end

      expect(Souls.configuration.project_id).to eq "elsoul"
    end
  end
end
