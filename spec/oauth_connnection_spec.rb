require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::OauthConnection do
  before do
    @consumer_mock = mock(OAuth::Consumer)
    @access_token_mock = mock(OAuth::AccessToken)
  end

  describe "access_token" do
    it "should create OAuth access token with credentials" do
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
      OAuth::AccessToken.should_receive(:new).with(@consumer_mock, 'AccessToken098', 'AccessSecret123')

      RightSignature::OauthConnection.access_token
    end
  end

  describe "request" do
    it "should create GET request with access token and path with custom headers" do
      @access_token_mock.should_receive(:get).with('path', {"User-Agent" => 'My own'})
      OAuth::AccessToken.stub(:new).and_return(@access_token_mock)

      RightSignature::OauthConnection.request(:get, "path", {"User-Agent" => 'My own'})
    end
  end

end