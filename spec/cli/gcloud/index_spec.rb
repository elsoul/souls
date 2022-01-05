RSpec.describe(SOULs::Gcloud) do
  describe "auth_login" do
    it "should return true if everything OK" do
      gc = SOULs::Gcloud.new
      allow(gc).to(receive(:system).and_return(true))
      expect(gc.auth_login).to(eq(true))
    end

    it "should throw exception if everything OK" do
      gc = SOULs::Gcloud.new
      allow(gc).to(receive(:system).and_return(false))
      expect { gc.auth_login }
        .to(raise_error(SOULs::GcloudException))
    end
  end

  describe "config_set" do
    it "should return true if everything OK" do
      gc = SOULs::Gcloud.new
      allow(gc).to(receive(:system).and_return(true))
      expect(gc.config_set).to(eq(true))
    end

    it "should throw exception if everything OK" do
      gc = SOULs::Gcloud.new
      allow(gc).to(receive(:system).and_return(false))
      expect { gc.config_set }
        .to(raise_error(SOULs::GcloudException))
    end
  end

  describe "enable_permissions" do
    it "should return true if everything OK" do
      gc = SOULs::Gcloud.new
      allow(gc).to(receive(:system).and_return(true))
      expect(gc.enable_permissions).to(eq(true))
    end
  end
end
