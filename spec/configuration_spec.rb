require File.dirname(__FILE__) + '/../lib/rightsignature'

describe RightSignature do
  describe "load_configuration" do
    it "should load api_token into configurations[:api_token]" do
      rs = RightSignature::Connection.new(:api_token => "MyToken")
      rs.configuration[:api_token].should == "MyToken"
    end

    it "should load OAuth consumer key, consumer secret, access token and access secret" do
      rs = RightSignature::Connection.new(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      rs.configuration[:consumer_key].should == "key"
      rs.configuration[:consumer_secret].should == "secret"
      rs.configuration[:access_token].should == "atoken"
      rs.configuration[:access_secret].should == "asecret"
    end
  end

  describe "check_credentials" do
    it "should raise error if configuration is not set" do
      rs = RightSignature::Connection.new()
      lambda {rs.check_credentials}.should raise_error
    end

    it "should raise error if api_token is blank and oauth credentials are not set" do
      rs = RightSignature::Connection.new(:api_token => " ")
      lambda {rs.check_credentials}.should raise_error
    end

    it "should raise error if consumer_key, consumer_secret, access_token, or access_secret is not set" do
      rs = RightSignature::Connection.new(:consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      lambda {rs.check_credentials}.should raise_error

      rs = RightSignature::Connection.new(:consumer_key => "key", :access_token => "atoken", :access_secret => "asecret")
      lambda {rs.check_credentials}.should raise_error

      rs = RightSignature::Connection.new(:consumer_key => "key", :consumer_secret => "secret", :access_secret => "asecret")
      lambda {rs.check_credentials}.should raise_error

      rs = RightSignature::Connection.new(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken")
      lambda {rs.check_credentials}.should raise_error
    end

    it "should not raise error if consumer_key, consumer_secret, access_token, and access_secret is set" do
      rs = RightSignature::Connection.new(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      rs.check_credentials
    end

    it "should not raise error if api_token is set" do
      rs = RightSignature::Connection.new(:api_token => "asdf")
      rs.check_credentials
    end
  end

  describe "has_api_token?" do
    it "should be false if configuration is not set" do
      rs = RightSignature::Connection.new()
      rs.has_api_token?.should be false
    end

    it "should be false if api_token is blank" do
      rs = RightSignature::Connection.new(:api_token => "   ")
      rs.has_api_token?.should be false
    end

    it "should be true if api_token is set" do
      rs = RightSignature::Connection.new(:api_token => "abc")
      rs.has_api_token?.should be true
    end

  end

  describe "has_oauth_credentials?" do
    it "should be false if configuration is not set" do
      rs = RightSignature::Connection.new()
      rs.has_oauth_credentials?.should be false
    end

    it "should be false if consumer_key, consumer_secret, access_token, or access_secret is not set" do
      rs = RightSignature::Connection.new(:consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      rs.has_oauth_credentials?.should be false

      rs = RightSignature::Connection.new(:consumer_key => "key", :access_token => "atoken", :access_secret => "asecret")
      rs.has_oauth_credentials?.should be false

      rs = RightSignature::Connection.new(:consumer_key => "key", :consumer_secret => "secret", :access_secret => "asecret")
      rs.has_oauth_credentials?.should be false

      rs = RightSignature::Connection.new(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken")
      rs.has_oauth_credentials?.should be false
    end

    it "should be true if consumer_key, consumer_secret, access_token, and access_secret is set" do
      rs = RightSignature::Connection.new(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      rs.has_oauth_credentials?.should be true
    end
  end
end
