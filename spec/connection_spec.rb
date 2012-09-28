require File.dirname(__FILE__) + '/../lib/rightsignature'

describe RightSignature::Connection do
  before do
    @net_http_response = Net::HTTPOK.new('1.1', 200, 'OK')
    @net_http_response.stub(:body => '')
    @httparty_response = stub("HTTPartyResponse", :parsed_response => nil, :body => '', :success? => true)
  end

  describe "GET" do
    describe "connection method" do
      it "should default to RightSignature::57 if no api_token was specified" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.should_receive(:request).and_return(@net_http_response)
        RightSignature::Connection.get("/path")
      end

      it "should use RightSignature::TokenConnection if api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
        RightSignature::Connection.get("/path")
      end

      it "should use RightSignature::TokenConnection if only api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN"}
        RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
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
        @net_http_response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
        RightSignature::OauthConnection.should_receive(:request).with(:get, "/path?page=1&q=search%20me", {}).and_return(@net_http_response)
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1})
      end

      it "should return converted response body from XML to hash" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        response = Net::HTTPSuccess.new('1.1', 200, 'OK')
        response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
        RightSignature::OauthConnection.should_receive(:request).with(:get, "/path?page=1&q=search%20me", {}).and_return(response)
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1}).should == {'document' => {'subject' => "My Subject"}}
      end
    end

    describe "using TokenConnection" do
      it "should append params and header into query option and header option" do
        RightSignature::configuration = {:api_token => 'token'}
        RightSignature::TokenConnection.should_receive(:request).with(:get, "/path", {:query => {:q => 'search me', :page => 1}, :headers => {"User-Agent" => "me"}}).and_return(@httparty_response)
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1}, {"User-Agent" => "me"})
      end

      it "should return converted parsed_response from response" do
        RightSignature::configuration = {:api_token => 'token'}
        @httparty_response.should_receive(:parsed_response).and_return({'document' => {'subject' => "My Subject"}})
        RightSignature::TokenConnection.stub(:request).and_return(@httparty_response)
        RightSignature::Connection.get("/path", {:q => 'search me', :page => 1}).should == {'document' => {'subject' => "My Subject"}}
      end
    end
  end

  describe "POST" do
    describe "connection method" do
      before do
        RightSignature::TokenConnection.stub(:request => @net_http_response)
        RightSignature::OauthConnection.stub(:request => @httparty_response)
      end

      it "should default to RightSignature::OauthConnection if no api_token was specified" do
        RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::OauthConnection.should_receive(:request).and_return(@net_http_response)
        RightSignature::Connection.post("/path")
      end

      it "should default to RightSignature::TokenConnection if api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
        RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
        RightSignature::Connection.post("/path")
      end

      it "should default to RightSignature::TokenConnection if only api_token was specified" do
        RightSignature::configuration = {:api_token => "APITOKEN"}
        RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
        RightSignature::Connection.post("/path")
      end

      it "should raise error if no configuration is set" do
        RightSignature::configuration = nil
        lambda{RightSignature::Connection.post("/path")}.should raise_error
      end
    end

    
    describe "DELETE" do
      describe "connection method" do
        it "should default to RightSignature::57 if no api_token was specified" do
          RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          RightSignature::OauthConnection.should_receive(:request).and_return(@net_http_response)
          RightSignature::Connection.delete("/path")
        end

        it "should use RightSignature::TokenConnection if api_token was specified" do
          RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
          RightSignature::Connection.delete("/path")
        end

        it "should use RightSignature::TokenConnection if only api_token was specified" do
          RightSignature::configuration = {:api_token => "APITOKEN"}
          RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
          RightSignature::Connection.delete("/path")
        end
      end

      it "should raise error if no configuration is set" do
        RightSignature::configuration = nil
        lambda{RightSignature::Connection.delete("/path")}.should raise_error
      end

      describe "using OauthConnection" do
        it "should return converted response body from XML to hash" do
          RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          response = Net::HTTPSuccess.new('1.1', 200, 'OK')
          response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          RightSignature::OauthConnection.should_receive(:request).with(:delete, "/path", {}).and_return(response)
          RightSignature::Connection.delete("/path").should == {'document' => {'subject' => "My Subject"}}
        end

        it "should pass headers" do
          RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          response = Net::HTTPSuccess.new('1.1', 200, 'OK')
          response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          RightSignature::OauthConnection.should_receive(:request).with(:delete, "/path", {"User-Agent" => "custom"}).and_return(response)
          RightSignature::Connection.delete("/path", {"User-Agent" => "custom"}).should == {'document' => {'subject' => "My Subject"}}
        end
      end

      describe "using TokenConnection" do
        it "should append headers into headers option" do
          RightSignature::configuration = {:api_token => 'token'}
          RightSignature::TokenConnection.should_receive(:request).with(:delete, "/path", {:headers => {"User-Agent" => "me"}}).and_return(@httparty_response)
          RightSignature::Connection.delete("/path", {"User-Agent" => "me"})
        end

        it "should return converted parsed_response from response" do
          RightSignature::configuration = {:api_token => 'token'}
          @httparty_response.should_receive(:parsed_response).and_return({'document' => {'subject' => "My Subject"}})
          RightSignature::TokenConnection.stub(:request).and_return(@httparty_response)
          RightSignature::Connection.delete("/path").should == {'document' => {'subject' => "My Subject"}}
        end
      end
    end

    describe "PUT" do
      describe "connection method" do
        it "should default to RightSignature::57 if no api_token was specified" do
          RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          RightSignature::OauthConnection.should_receive(:request).and_return(@net_http_response)
          RightSignature::Connection.get("/path")
        end

        it "should use RightSignature::TokenConnection if api_token was specified" do
          RightSignature::configuration = {:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
          RightSignature::Connection.put("/path")
        end

        it "should use RightSignature::TokenConnection if only api_token was specified" do
          RightSignature::configuration = {:api_token => "APITOKEN"}
          RightSignature::TokenConnection.should_receive(:request).and_return(@httparty_response)
          RightSignature::Connection.put("/path")
        end
      end

      it "should raise error if no configuration is set" do
        RightSignature::configuration = nil
        lambda{RightSignature::Connection.put("/path")}.should raise_error
      end

      describe "using OauthConnection" do
        it "should convert body into XML" do
          RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          @net_http_response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          RightSignature::OauthConnection.should_receive(:request).with(:put, "/path", "<document><something>else</something><page>1</page></document>", {}).and_return(@net_http_response)
          RightSignature::Connection.put("/path", {:document => {:something => "else", :page => 1}})
        end

        it "should return converted response body from XML to hash" do
          RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"}
          response = Net::HTTPSuccess.new('1.1', 200, 'OK')
          response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          RightSignature::OauthConnection.should_receive(:request).with(:put, "/path", "<document><something>else</something><page>1</page></document>", {}).and_return(response)
          RightSignature::Connection.put("/path", {:document => {:something => "else", :page => 1}}).should == {'document' => {'subject' => "My Subject"}}
        end
      end

      describe "using TokenConnection" do
        it "should append params and header into query option and header option" do
          RightSignature::configuration = {:api_token => 'token'}
          RightSignature::TokenConnection.should_receive(:request).with(:put, "/path", {:body => "<document><something>else</something><page>1</page></document>", :headers => {"User-Agent" => "me"}}).and_return(@httparty_response)
          RightSignature::Connection.put("/path", {:document => {:something => "else", :page => 1}}, {"User-Agent" => "me"})
        end

        it "should return converted parsed_response from response" do
          RightSignature::configuration = {:api_token => 'token'}
          @httparty_response.should_receive(:parsed_response).and_return({'document' => {'subject' => "My Subject"}})
          RightSignature::TokenConnection.stub(:request).and_return(@httparty_response)
          RightSignature::Connection.put("/path", {:document => {:something => "else", :page => 1}}).should == {'document' => {'subject' => "My Subject"}}
        end
      end
    end
    
  end
end
