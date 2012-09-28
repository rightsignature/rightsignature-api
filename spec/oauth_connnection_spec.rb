require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::OauthConnection do
  before do
    @consumer_mock = mock(OAuth::Consumer)
    @access_token_mock = mock(OAuth::AccessToken)
  end

  describe "oauth_consumer" do
    after do
      # Reset caching of oauth_consumer
      RightSignature::OauthConnection.instance_variable_set("@oauth_consumer", nil)
    end

    it "should raise error if no configuration is set" do
      RightSignature::configuration = {}
      lambda{RightSignature::OauthConnection.oauth_consumer}.should raise_error(Exception, "Please set load_configuration with consumer_key, consumer_secret, access_token, access_secret")
    end
    
    it "should return consumer if consumer_key and consumer_secret is set" do
      RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098"}
      OAuth::Consumer.should_receive(:new).with(
        "Consumer123",
        "Secret098",
        {
         :site              => "https://rightsignature.com",
         :scheme            => :header,
         :http_method        => :post,
         :authorize_path    =>'/oauth/authorize', 
         :access_token_path =>'/oauth/access_token', 
         :request_token_path=>'/oauth/request_token'
        }).and_return(@consumer_mock)
      RightSignature::OauthConnection.oauth_consumer.should == @consumer_mock
    end
  end

  describe "access_token" do
    after do
      # Reset caching of oauth_consumer
      RightSignature::OauthConnection.instance_variable_set("@access_token", nil)
      RightSignature::OauthConnection.instance_variable_set("@oauth_consumer", nil)
    end
    
    it "should raise error if access_token is not set" do
      RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_secret => "Secret098"}
      lambda{RightSignature::OauthConnection.access_token}.should raise_error(Exception, "Please set load_configuration with consumer_key, consumer_secret, access_token, access_secret")
    end

    it "should raise error if access_secret is not set" do
      RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098"}
      lambda{RightSignature::OauthConnection.access_token}.should raise_error(Exception, "Please set load_configuration with consumer_key, consumer_secret, access_token, access_secret")
    end
    
    it "should create OAuth access token with credentials" do
      RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
      OAuth::Consumer.should_receive(:new).and_return(@consumer_mock)
      OAuth::AccessToken.should_receive(:new).with(@consumer_mock, 'AccessToken098', 'AccessSecret123')

      RightSignature::OauthConnection.access_token
    end
    
    describe "set_access_token" do
      it "should create new access_token with given token and secret" do
        OAuth::Consumer.stub(:new).and_return(@consumer_mock)
        OAuth::AccessToken.should_receive(:new).with(@consumer_mock, "newAToken", "newASecret").and_return(@access_token_mock)

        RightSignature::OauthConnection.set_access_token("newAToken","newASecret")
        RightSignature::OauthConnection.access_token.should == @access_token_mock
      end
    end
  end
  
  describe "new_request_token" do
    it "should generate new RequestToken from consumer" do
      request_mock = mock(OAuth::RequestToken)
      OAuth::Consumer.stub(:new).and_return(@consumer_mock)
      @consumer_mock.should_receive(:get_request_token).and_return(request_mock)
      RightSignature::OauthConnection.new_request_token
      RightSignature::OauthConnection.request_token.should == request_mock
    end
  end

  describe "generate_access_token" do
    it "should raise error if there is no request_token" do
      # Reset request_token cache"
      RightSignature::OauthConnection.instance_variable_set("@request_token", nil)
      lambda{RightSignature::OauthConnection.generate_access_token("verifi123")}.should raise_error(Exception, "Please set request token with new_request_token")
    end

    it "should get access token from request token with given verifier" do
      request_token_mock = mock(OAuth::RequestToken)
      request_token_mock.should_receive(:get_access_token).with({:oauth_verifier => "verifi123"}).and_return(@access_token_mock)
      RightSignature::OauthConnection.instance_variable_set("@request_token", request_token_mock)

      RightSignature::OauthConnection.generate_access_token("verifi123")
      RightSignature::OauthConnection.access_token.should == @access_token_mock
    end
  end

  describe "request" do
    it "should raise error if no configuration is set" do
      RightSignature::configuration = {}
      lambda{RightSignature::OauthConnection.request(:get, "path", {"User-Agent" => 'My own'})}.should raise_error(Exception, "Please set load_configuration with consumer_key, consumer_secret, access_token, access_secret")
    end
    
    it "should create GET request with access token and path with custom headers as 3rd argument" do
      @access_token_mock.should_receive(:get).with('path', {"User-Agent" => 'My own', "Accept"=>"*/*", "content-type"=>"application/xml"})
      RightSignature::OauthConnection.stub(:access_token).and_return(@access_token_mock)
      RightSignature::OauthConnection.request(:get, "path", {"User-Agent" => 'My own'})
    end

    it "should create POST request with access token and path with body as 3rd argument and custom headers as 4th argument" do
      @access_token_mock.should_receive(:post).with('path', "<template></template>", {"User-Agent" => 'My own', "Accept"=>"*/*", "content-type"=>"application/xml"})
      RightSignature::OauthConnection.stub(:access_token).and_return(@access_token_mock)
      RightSignature::OauthConnection.request(:post, "path", "<template></template>", {"User-Agent" => 'My own'})
    end
  end

end