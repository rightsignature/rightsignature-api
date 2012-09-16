require File.dirname(__FILE__) + '/../lib/rightsignature'

describe RightSignature::configuration do
  describe "load_configuration" do
    it "should load api_token into configurations[:api_token]" do
      RightSignature::load_configuration(:api_token => "MyToken")
      RightSignature::configuration[:api_token].should == "MyToken"
    end
  
    it "should load OAuth consumer key, consumer secret, access token and access secret" do
      RightSignature::load_configuration(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      RightSignature::configuration[:consumer_key].should == "key"
      RightSignature::configuration[:consumer_secret].should == "secret"
      RightSignature::configuration[:access_token].should == "atoken"
      RightSignature::configuration[:access_secret].should == "asecret"
    end
  end

  describe "check_credentials" do
    it "should raise error if configuration is not set" do
      RightSignature::load_configuration()
      lambda {RightSignature::check_credentials}.should raise_error
    end

    it "should raise error if api_token is blank and oauth credentials are not set" do
      RightSignature::load_configuration(:api_token => " ")
      lambda {RightSignature::check_credentials}.should raise_error
    end

    it "should raise error if consumer_key, consumer_secret, access_token, or access_secret is not set" do
      RightSignature::load_configuration(:consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      lambda {RightSignature::check_credentials}.should raise_error

      RightSignature::load_configuration(:consumer_key => "key", :access_token => "atoken", :access_secret => "asecret")
      lambda {RightSignature::check_credentials}.should raise_error

      RightSignature::load_configuration(:consumer_key => "key", :consumer_secret => "secret", :access_secret => "asecret")
      lambda {RightSignature::check_credentials}.should raise_error

      RightSignature::load_configuration(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken")
      lambda {RightSignature::check_credentials}.should raise_error
    end

    it "should not raise error if consumer_key, consumer_secret, access_token, and access_secret is set" do
      RightSignature::load_configuration(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      RightSignature::check_credentials
    end

    it "should not raise error if api_token is set" do
      RightSignature::load_configuration(:api_token => "asdf")
      RightSignature::check_credentials
    end
  end
  
  describe "has_api_token?" do
    it "should be false if configuration is not set" do
      RightSignature::load_configuration()
      RightSignature::has_api_token?.should be_false
    end

    it "should be false if api_token is blank" do
      RightSignature::load_configuration(:api_token => "   ")
      RightSignature::has_api_token?.should be_false
    end

    it "should be true if api_token is set" do
      RightSignature::load_configuration(:api_token => "abc")
      RightSignature::has_api_token?.should be_true
    end
    
  end

  describe "has_oauth_credentials?" do
    it "should be false if configuration is not set" do
      RightSignature::load_configuration()
      RightSignature::has_oauth_credentials?.should be_false
    end

    it "should be false if consumer_key, consumer_secret, access_token, or access_secret is not set" do
      RightSignature::load_configuration(:consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      RightSignature::has_oauth_credentials?.should be_false

      RightSignature::load_configuration(:consumer_key => "key", :access_token => "atoken", :access_secret => "asecret")
      RightSignature::has_oauth_credentials?.should be_false

      RightSignature::load_configuration(:consumer_key => "key", :consumer_secret => "secret", :access_secret => "asecret")
      RightSignature::has_oauth_credentials?.should be_false

      RightSignature::load_configuration(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken")
      RightSignature::has_oauth_credentials?.should be_false
    end

    it "should be true if consumer_key, consumer_secret, access_token, and access_secret is set" do
      RightSignature::load_configuration(:consumer_key => "key", :consumer_secret => "secret", :access_token => "atoken", :access_secret => "asecret")
      RightSignature::has_oauth_credentials?.should be_true
    end
  end
end