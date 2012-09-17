require File.dirname(__FILE__) + '/../lib/rightsignature'

describe RightSignature::Connection do
  describe "GET" do
    describe "connection method" do
      it "should default to RightSignature::OauthConnection if no api_token was specified" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.should_receive(:request).and_return(stub('Response', :body => ''))
        RightSignature::Connection.get("/path")
      end

      it "should use RightSignature::TokenConnection if api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::TokenConnection.should_receive(:request).and_return(stub('Response', :parsed_response => {}))
        RightSignature::Connection.get("/path")
      end

      it "should use RightSignature::TokenConnection if only api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN"}
        RightSignature::TokenConnection.should_receive(:request).and_return(stub('Response', :parsed_response => {}))
        RightSignature::Connection.get("/path")
      end
    end
    
    it "should raise error if no configuration is set" do
      RightSignature::configuration = nil
      lambda{RightSignature::Connection.get("/path")}.should raise_error
    end
    
    describe "using OauthConnection" do
      it "should append params into path alphabetically and URI escaped" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.should_receive(:request).with(:get, "/path?page=1&q=search%20me", {}).and_return(stub('Response', :body => '<document><subject>My Subject</subject></document>'))
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1})
      end

      it "should return converted response body from XML to hash" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.stub(:request).and_return(stub('Response', :body => '<document><subject>My Subject</subject></document>'))
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1}).should == {'document' => {'subject' => "My Subject"}}
      end
    end

    describe "using TokenConnection" do
      it "should append params and header into query option and header option" do
        RightSignature::configuration = {:api_token => 'token'}
        RightSignature::TokenConnection.should_receive(:request).with(:get, "/path", {:query => {:q => 'search me', :page => 1}, :headers => {"User-Agent" => "me"}}).and_return(stub('Response', :parsed_response => {}))
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1}, {"User-Agent" => "me"})
      end

      it "should return converted parsed_response from response" do
        RightSignature::configuration = {:api_token => 'token'}
        RightSignature::TokenConnection.stub(:request).and_return(stub('Response', :parsed_response => {'document' => {'subject' => "My Subject"}}))
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1}).should == {'document' => {'subject' => "My Subject"}}
      end
    end
  end

  describe "POST" do
    describe "connection method" do
      it "should default to RightSignature::OauthConnection if no api_token was specified" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.should_receive(:request).and_return(stub('Response', :body => ''))
        RightSignature::Connection.post("/path")
      end

      it "should default to RightSignature::TokenConnection if api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::TokenConnection.should_receive(:request).and_return(stub('Response', :parsed_response => {}))
        RightSignature::Connection.post("/path")
      end

      it "should default to RightSignature::TokenConnection if only api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN"}
        RightSignature::TokenConnection.should_receive(:request).and_return(stub('Response', :parsed_response => {}))
        RightSignature::Connection.post("/path")
      end

      it "should raise error if no configuration is set" do
        RightSignature::configuration = nil
        lambda{RightSignature::Connection.post("/path")}.should raise_error
      end
    end
    
    
  end
end
