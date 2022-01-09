RSpec.describe(SOULs::SOULsMutation) do
  describe "souls_fb_auth" do
    it "should raise ArgumentError with no payload" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      allow_any_instance_of(FirebaseIdToken::Certificates).to(receive(:request!).and_return(true))
      allow_any_instance_of(FirebaseIdToken::Signature).to(receive(:verify).and_return(nil))

      expectval =
        expect do
          cli.souls_fb_auth(token: "abc")
        end

      expectval.to(raise_error(ArgumentError))
    end

    it "should return payload if payload has token" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      allow_any_instance_of(FirebaseIdToken::Certificates).to(receive(:request!).and_return(true))
      allow_any_instance_of(FirebaseIdToken::Signature).to(receive(:verify).and_return("abc123"))

      result = cli.souls_fb_auth(token: "test")
      expect(result).to(eq("abc123"))
    end
  end

  describe "publish_pubsub_queue" do
    it "should call publish" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      allow(Google::Cloud::Pubsub).to(receive(:new).and_return(Google::Cloud::Pubsub::Project.new("abc")))
      allow_any_instance_of(Google::Cloud::Pubsub::Project).to(
        receive(:topic).and_return(
          Google::Cloud::Pubsub::Project.new("abc")
        )
      )
      allow_any_instance_of(Google::Cloud::Pubsub::Project).to(receive(:publish).and_return(true))
      result = cli.souls_publish_pubsub_queue(topic_name: "send-mail-job", message: "text!")
      expect(result).to(eq(true))
    end
  end

  describe "make_graphql_query" do
    it "should make query string from string and arguments" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      expected_result = "query { mailer(key: \"value\" key2: \"value2\" ) { response } }"
      result = cli.souls_make_graphql_query(query: "mailer", args: { key: "value", key2: "value2" })
      expect(result).to(eq(expected_result))
    end
  end

  describe "souls_post_to_dev" do
    it "should send post request to development" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      allow(cli).to(receive(:souls_get_worker).and_return([{ port: "4000" }]))
      allow(Net::HTTP).to(receive(:post_form).and_return(Net::HTTPResponse.new(1.0, 200, "OK")))
      allow_any_instance_of(Net::HTTPResponse).to(receive(:body).and_return("abc123"))

      expect(cli.souls_post_to_dev).to(eq("abc123"))
    end
  end

  describe "souls_get_worker" do
    it "should search for worker from configuation" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      result = cli.souls_get_worker(worker_name: "abc123")
      expect(result).to(eq([]))
    end
  end

  describe "souls_auth_check" do
    it "should raise error if no user" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      expectresult =
        expect do
          cli.souls_auth_check({})
        end
      expectresult.to(raise_error(GraphQL::ExecutionError))
    end

    it "should not raise error if user" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      expect(cli.souls_auth_check({ user: "test" })).to(eq(nil))
    end
  end

  describe "production?" do
    it "should return false when not production" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      expect(cli.production?).to(eq(false))
    end
  end

  describe "get_instance_id" do
    it "should curl instance ID" do
      cli = SOULs::SOULsMutation.new(object: [], context: [], field: [])
      allow(cli).to(receive(:`).and_return(true))
      expect(cli).to(
        receive(:`).with(
          "curl http://metadata.google.internal/computeMetadata/v1/instance/id -H Metadata-Flavor:Google"
        )
      )

      expect(cli.get_instance_id).to(eq(true))
    end
  end
end
