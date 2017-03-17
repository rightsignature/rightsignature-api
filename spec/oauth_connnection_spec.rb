require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::OauthConnection do
  before do
    @consumer_mock = double(OAuth::Consumer)
    @access_token_mock = double(OAuth::AccessToken, :token => "token", :secret => "secret")
  end

  describe "oauth_consumer" do
    after do
      # Reset caching of oauth_consumer
      @oauth_connection.instance_variable_set("@oauth_consumer", nil)
    end

    it "should raise error if no configuration is set" do
      @oauth_connection = RightSignature::OauthConnection.new()
      lambda{@oauth_connection.oauth_consumer}.should raise_error(Exception, "Please set consumer_key, consumer_secret, access_token, access_secret")
    end

    it "should return consumer if consumer_key and consumer_secret is set" do
      @oauth_connection = RightSignature::OauthConnection.new(:consumer_key => "Consumer123", :consumer_secret => "Secret098")
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
      @oauth_connection.oauth_consumer.should == @consumer_mock
    end
  end

  describe "access_token" do
    it "should raise error if access_token is not set" do
      oauth_connection = RightSignature::OauthConnection.new(:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_secret => "Secret098")
      lambda{oauth_connection.access_token}.should raise_error(Exception, "Please set consumer_key, consumer_secret, access_token, access_secret")
    end

    it "should raise error if access_secret is not set" do
      oauth_connection = RightSignature::OauthConnection.new(:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098")
      lambda{oauth_connection.access_token}.should raise_error(Exception, "Please set consumer_key, consumer_secret, access_token, access_secret")
    end

    it "should create OAuth access token with credentials" do
      oauth_connection = RightSignature::OauthConnection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
      OAuth::Consumer.should_receive(:new).and_return(@consumer_mock)
      OAuth::AccessToken.should_receive(:new).with(@consumer_mock, 'AccessToken098', 'AccessSecret123')

      oauth_connection.access_token
    end

    describe "set_access_token" do
      it "should create new access_token with given token and secret" do
        OAuth::Consumer.stub(:new).and_return(@consumer_mock)
        OAuth::AccessToken.should_receive(:new).with(@consumer_mock, "newAToken", "newASecret").and_return(@access_token_mock)

        oauth_connection = RightSignature::OauthConnection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
        oauth_connection.set_access_token("newAToken","newASecret")
        oauth_connection.access_token.should == @access_token_mock
      end
    end
  end

  describe "new_request_token" do
    it "should generate new RequestToken from consumer" do
      request_mock = double(OAuth::RequestToken)
      OAuth::Consumer.stub(:new).and_return(@consumer_mock)
      @consumer_mock.should_receive(:get_request_token).and_return(request_mock)

      oauth_connection = RightSignature::OauthConnection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
      oauth_connection.new_request_token
      oauth_connection.request_token.should == request_mock
    end

    it "should pass in options" do
      request_mock = double(OAuth::RequestToken)
      OAuth::Consumer.stub(:new).and_return(@consumer_mock)
      @consumer_mock.should_receive(:get_request_token).with({:oauth_callback => "http://example.com/callback"}).and_return(request_mock)

      oauth_connection = RightSignature::OauthConnection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
      oauth_connection.new_request_token({:oauth_callback => "http://example.com/callback"})
      oauth_connection.request_token.should == request_mock
    end
  end

  describe "set_request_token" do
    it "should create RequestToken with given token and secret" do
      oauth_connection = RightSignature::OauthConnection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098"})
      oauth_connection.set_request_token('request1', 'secret2')
      oauth_connection.request_token.token.should == 'request1'
      oauth_connection.request_token.secret.should == 'secret2'
    end
  end

  describe "generate_access_token" do
    before do
      @oauth_connection = RightSignature::OauthConnection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098"})
    end

    it "should raise error if there is no request_token" do
      # Reset request_token cache"
      @oauth_connection.instance_variable_set("@request_token", nil)
      lambda{@oauth_connection.generate_access_token("verifi123")}.should raise_error(Exception, "Please set request token with new_request_token")
    end

    it "should get access token from request token with given verifier" do
      request_token_mock = double(OAuth::RequestToken)
      request_token_mock.should_receive(:get_access_token).with({:oauth_verifier => "verifi123"}).and_return(@access_token_mock)
      @oauth_connection.instance_variable_set("@request_token", request_token_mock)

      @oauth_connection.generate_access_token("verifi123")
      @oauth_connection.access_token.should == @access_token_mock
    end
  end

  describe "request" do
    before do
      @oauth_connection = RightSignature::OauthConnection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098"})
    end

    it "should raise error if no configuration is set" do
      oauth_connection = RightSignature::OauthConnection.new()
      lambda{oauth_connection.request(:get, "path", {"User-Agent" => 'My own'})}.should raise_error(Exception, "Please set consumer_key, consumer_secret, access_token, access_secret")
    end

    it "should create GET request with access token and path with custom headers as 3rd argument" do
      @access_token_mock.should_receive(:get).with('path', {"User-Agent" => 'My own', "Accept"=>"*/*", "content-type"=>"application/xml"})
      @oauth_connection.stub(:access_token).and_return(@access_token_mock)
      @oauth_connection.request(:get, "path", {"User-Agent" => 'My own'})
    end

    it "should create POST request with access token and path with body as 3rd argument and custom headers as 4th argument" do
      @access_token_mock.should_receive(:post).with('path', "<template></template>", {"User-Agent" => 'My own', "Accept"=>"*/*", "content-type"=>"application/xml"})
      @oauth_connection.stub(:access_token).and_return(@access_token_mock)
      @oauth_connection.request(:post, "path", "<template></template>", {"User-Agent" => 'My own'})
    end
  end

end
