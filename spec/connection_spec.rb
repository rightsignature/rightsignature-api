require File.dirname(__FILE__) + '/../lib/rightsignature'

describe RightSignature::Connection do
  describe "GET" do
    describe "connection method" do
      it "should default to RightSignature::OauthConnection if no api_token was specified" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.should_receive(:request)
        RightSignature::Connection.get("/path")
      end

      it "should use RightSignature::TokenConnection if api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::TokenConnection.should_receive(:request)
        RightSignature::Connection.get("/path")
      end

      it "should use RightSignature::TokenConnection if only api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN"}
        RightSignature::TokenConnection.should_receive(:request)
        RightSignature::Connection.get("/path")
      end
    end
    
    it "should raise error if no configuration is set" do
      RightSignature::configuration = nil
      lambda{RightSignature::Connection.get("/path")}.should raise_error
    end
  end

  describe "POST" do
    describe "connection method" do
      it "should default to RightSignature::OauthConnection if no api_token was specified" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.should_receive(:request)
        RightSignature::Connection.post("/path")
      end

      it "should default to RightSignature::TokenConnection if api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::TokenConnection.should_receive(:request)
        RightSignature::Connection.post("/path")
      end

      it "should default to RightSignature::TokenConnection if only api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN"}
        RightSignature::TokenConnection.should_receive(:request)
        RightSignature::Connection.post("/path")
      end

      it "should raise error if no configuration is set" do
        RightSignature::configuration = nil
        lambda{RightSignature::Connection.post("/path")}.should raise_error
      end
    end
    
    
  end
end
