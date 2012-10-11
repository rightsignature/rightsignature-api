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
        @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
        @rs.oauth_connection.should_receive(:request).and_return(@net_http_response)
        @rs.get("/path")
      end

      it "should use Token Connection if api_token was specified" do
        @rs = RightSignature::Connection.new({:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
        @rs.token_connection.should_receive(:request).and_return(@httparty_response)
        @rs.get("/path")
      end

      it "should use Token Connection if only api_token was specified" do
        @rs = RightSignature::Connection.new({:api_token => "APITOKEN"})
        @rs.token_connection.should_receive(:request).and_return(@httparty_response)
        @rs.get("/path")
      end
    end
    
    it "should raise error if no configuration is set" do
      @rs = RightSignature::Connection.new({})
      lambda{@rs.get("/path")}.should raise_error
    end
    
    describe "using OauthConnection" do
      it "should append params into path alphabetically and URI escaped" do
        @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
        @net_http_response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
        @rs.oauth_connection.should_receive(:request).with(:get, "/path?page=1&q=search%20me", {}).and_return(@net_http_response)
        @rs.get("/path", {:q => 'search me', :page => 1})
      end

      it "should return converted response body from XML to hash" do
        @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
        response = Net::HTTPSuccess.new('1.1', 200, 'OK')
        response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
        @rs.oauth_connection.should_receive(:request).with(:get, "/path?page=1&q=search%20me", {}).and_return(response)
        @rs.get("/path", {:q => 'search me', :page => 1}).should == {'document' => {'subject' => "My Subject"}}
      end
    end

    describe "using TokenConnection" do
      it "should append params and header into query option and header option" do
        @rs = RightSignature::Connection.new({:api_token => 'token'})
        @rs.token_connection.should_receive(:request).with(:get, "/path", {:query => {:q => 'search me', :page => 1}, :headers => {"User-Agent" => "me"}}).and_return(@httparty_response)
        @rs.get("/path", {:q => 'search me', :page => 1}, {"User-Agent" => "me"})
      end

      it "should return converted parsed_response from response" do
        @rs = RightSignature::Connection.new({:api_token => 'token'})
        @httparty_response.should_receive(:parsed_response).and_return({'document' => {'subject' => "My Subject"}})
        @rs.token_connection.stub(:request).and_return(@httparty_response)
        @rs.get("/path", {:q => 'search me', :page => 1}).should == {'document' => {'subject' => "My Subject"}}
      end
    end
  end

  describe "POST" do
    describe "connection method" do
      before do
        @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
        @rs.token_connection.stub(:request => @net_http_response)
        @rs.oauth_connection.stub(:request => @httparty_response)
      end

      it "should default to Oauth Connection if no api_token was specified" do
        @rs.oauth_connection.should_receive(:request).and_return(@net_http_response)
        @rs.post("/path")
      end

      it "should default to Token Connection if api_token was specified" do
        @rs = RightSignature::Connection.new({:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
        @rs.token_connection.should_receive(:request).and_return(@httparty_response)
        @rs.post("/path")
      end

      it "should default to Token Connection if only api_token was specified" do
        @rs = RightSignature::Connection.new({:api_token => "APITOKEN"})
        @rs.token_connection.should_receive(:request).and_return(@httparty_response)
        @rs.post("/path")
      end

      it "should raise error if no configuration is set" do
        @rs = RightSignature::Connection.new({})
        lambda{@rs.post("/path")}.should raise_error
      end
    end

    
    describe "DELETE" do
      describe "connection method" do
        it "should default to RightSignature::57 if no api_token was specified" do
          @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          @rs.oauth_connection.should_receive(:request).and_return(@net_http_response)
          @rs.delete("/path")
        end

        it "should use Token Connection if api_token was specified" do
          @rs = RightSignature::Connection.new({:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          @rs.token_connection.should_receive(:request).and_return(@httparty_response)
          @rs.delete("/path")
        end

        it "should use Token Connection if only api_token was specified" do
          @rs = RightSignature::Connection.new({:api_token => "APITOKEN"})
          @rs.token_connection.should_receive(:request).and_return(@httparty_response)
          @rs.delete("/path")
        end
      end

      it "should raise error if no configuration is set" do
        @rs = RightSignature::Connection.new({})
        lambda{@rs.delete("/path")}.should raise_error
      end

      describe "using OauthConnection" do
        it "should return converted response body from XML to hash" do
          @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          response = Net::HTTPSuccess.new('1.1', 200, 'OK')
          response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          @rs.oauth_connection.should_receive(:request).with(:delete, "/path", {}).and_return(response)
          @rs.delete("/path").should == {'document' => {'subject' => "My Subject"}}
        end

        it "should pass headers" do
          @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          response = Net::HTTPSuccess.new('1.1', 200, 'OK')
          response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          @rs.oauth_connection.should_receive(:request).with(:delete, "/path", {"User-Agent" => "custom"}).and_return(response)
          @rs.delete("/path", {"User-Agent" => "custom"}).should == {'document' => {'subject' => "My Subject"}}
        end
      end

      describe "using TokenConnection" do
        it "should append headers into headers option" do
          @rs = RightSignature::Connection.new({:api_token => 'token'})
          @rs.token_connection.should_receive(:request).with(:delete, "/path", {:headers => {"User-Agent" => "me"}}).and_return(@httparty_response)
          @rs.delete("/path", {"User-Agent" => "me"})
        end

        it "should return converted parsed_response from response" do
          @rs = RightSignature::Connection.new({:api_token => 'token'})
          @httparty_response.should_receive(:parsed_response).and_return({'document' => {'subject' => "My Subject"}})
          @rs.token_connection.stub(:request).and_return(@httparty_response)
          @rs.delete("/path").should == {'document' => {'subject' => "My Subject"}}
        end
      end
    end

    describe "PUT" do
      describe "connection method" do
        it "should default to RightSignature::57 if no api_token was specified" do
          @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          @rs.oauth_connection.should_receive(:request).and_return(@net_http_response)
          @rs.get("/path")
        end

        it "should use Token Connection if api_token was specified" do
          @rs = RightSignature::Connection.new({:api_token => "APITOKEN", :consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          @rs.token_connection.should_receive(:request).and_return(@httparty_response)
          @rs.put("/path")
        end

        it "should use Token Connection if only api_token was specified" do
          @rs = RightSignature::Connection.new({:api_token => "APITOKEN"})
          @rs.token_connection.should_receive(:request).and_return(@httparty_response)
          @rs.put("/path")
        end
      end

      it "should raise error if no configuration is set" do
        @rs = RightSignature::Connection.new({})
        lambda{@rs.put("/path")}.should raise_error
      end

      describe "using OauthConnection" do
        it "should convert body into XML" do
          @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          @net_http_response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          @rs.oauth_connection.should_receive(:request).with(:put, "/path", "<document><something>else</something><page>1</page></document>", {}).and_return(@net_http_response)
          @rs.put("/path", {:document => {:something => "else", :page => 1}})
        end

        it "should return converted response body from XML to hash" do
          @rs = RightSignature::Connection.new({:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123"})
          response = Net::HTTPSuccess.new('1.1', 200, 'OK')
          response.stub(:body).and_return('<document><subject>My Subject</subject></document>')
          @rs.oauth_connection.should_receive(:request).with(:put, "/path", "<document><something>else</something><page>1</page></document>", {}).and_return(response)
          @rs.put("/path", {:document => {:something => "else", :page => 1}}).should == {'document' => {'subject' => "My Subject"}}
        end
      end

      describe "using TokenConnection" do
        it "should append params and header into query option and header option" do
          @rs = RightSignature::Connection.new({:api_token => 'token'})
          @rs.token_connection.should_receive(:request).with(:put, "/path", {:body => "<document><something>else</something><page>1</page></document>", :headers => {"User-Agent" => "me"}}).and_return(@httparty_response)
          @rs.put("/path", {:document => {:something => "else", :page => 1}}, {"User-Agent" => "me"})
        end

        it "should return converted parsed_response from response" do
          @rs = RightSignature::Connection.new({:api_token => 'token'})
          @httparty_response.should_receive(:parsed_response).and_return({'document' => {'subject' => "My Subject"}})
          @rs.token_connection.stub(:request).and_return(@httparty_response)
          @rs.put("/path", {:document => {:something => "else", :page => 1}}).should == {'document' => {'subject' => "My Subject"}}
        end
      end
    end
    
  end
end
