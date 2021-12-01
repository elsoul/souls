RSpec.describe(Souls::SoulsMutation) do
  describe "fb_auth" do
    it "should raise ArgumentError with no payload" do
      cli = Souls::SoulsMutation.new(object: [], context: [], field: [])
      allow_any_instance_of(FirebaseIdToken::Certificates).to(receive(:request!).and_return(true))
      allow_any_instance_of(FirebaseIdToken::Signature).to(receive(:verify).and_return(nil))

      expect do
        cli.fb_auth(token: "abc")
      end.to(raise_error(ArgumentError))
    end

    it "should return payload if payload has token" do
    end
  end

  describe "publish_pubsub_queue" do
  end

  describe "make_graphql_query" do
  end

  describe "post_to_dev" do
  end

  describe "get_worker" do
  end

  describe "auth_check" do
  end

  describe "get_token" do
  end

  describe "production?" do
  end

  describe "get_instance_id" do
  end
end
