require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::ResponseError do
  describe "For OAuth response" do
    before do
      @net_http_response = Net::HTTPSuccess.new('1.1', '200', 'OK')
      @error = RightSignature::ResponseError.new(@net_http_response)
    end

    it "response should return Net::HTTP response" do
      @error.response.should == @net_http_response
    end

    it "code should return response code" do
      @error.code.should == '200'
    end

    describe "message" do
      it "should return response message" do
        @error.message.should == 'OK'
      end

      it "should return specified message" do
        error = RightSignature::ResponseError.new(@net_http_response, "No Way")
        error.message.should == 'No Way'
      end
    end
    
    describe "detailed_message" do
      it "should return error message from xml" do
        response = Net::HTTPNotAcceptable.new('1.1', 406, 'Not Acceptable')
        response.stub(:body).and_return('<error><message>Invalid GUID</message></error>')
        error = RightSignature::ResponseError.new(response)
        error.detailed_message.should == 'Invalid GUID'
      end

      it "should return nothing if response does not have error message node" do
        response = Net::HTTPNotFound.new('1.1', 404, 'Not Found')
        response.stub(:body).and_return('<html><body>Not Found</body></html>')
        error = RightSignature::ResponseError.new(response)
        error.detailed_message.should be_nil
      end
    end

    describe "common_solutions" do
      describe "on 406" do
        it "should suggest to check Content-Type header, url, or Accept header" do
          net_http_response = Net::HTTPNotAcceptable.new('1.1', '406', 'Not Acceptable')
          error = RightSignature::ResponseError.new(net_http_response)
          error.common_solutions.should match /Check the Content-Type/i
          error.common_solutions.should match /ensure url has \.xml or \.json/i
          error.common_solutions.should match /check 'Accept' header/i
        end
      end

      describe "on 401" do
        it "should suggest to check credentials" do
          net_http_response = Net::HTTPUnauthorized.new('1.1', '401', 'Unauthorized Access')
          error = RightSignature::ResponseError.new(net_http_response)
          error.common_solutions.should match /Check your credentials/i
        end
      end

      describe "on 500s" do
        it "should suggest to check xml or json format" do
          net_http_response = Net::HTTPInternalServerError.new('1.1', '500', 'Internal Server Error')
          error = RightSignature::ResponseError.new(net_http_response)
          error.common_solutions.should match /Check the format of your xml or json/i
        end
      end
    end
  end

  describe "For HTTParty response" do
    before do
      @net_http_response = Net::HTTPOK.new('1.1', 200, 'OK')
      @net_http_response.stub(:body =>"{}")

      @response = HTTParty::Response.new(HTTParty::Request.new(Net::HTTP::Get, '/'), @net_http_response, lambda { {} })
      @error = RightSignature::ResponseError.new(@response)
    end

    it "response should return HTTParty response" do
      @error.response.should == @response
    end

    it "code should return response code" do
      @error.code.should == 200
    end

    describe "message" do
      it "should return response message" do
        @error.message.should == 'OK'
      end
      it "should return specified message" do
        error = RightSignature::ResponseError.new(@response, "No Way")
        error.message.should == 'No Way'
      end
    end

    describe "detailed_message" do
      it "should return error message from xml" do
        net_http_response = Net::HTTPNotAcceptable.new('1.1', 406, 'Not Acceptable')
        net_http_response.stub(:body).and_return('<error><message>Invalid GUID</message></error>')
        response = HTTParty::Response.new(HTTParty::Request.new(Net::HTTP::Get, '/'), net_http_response, lambda{{"error" => {"message" => "Invalid GUID"}}})
        error = RightSignature::ResponseError.new(response)
        error.detailed_message.should == 'Invalid GUID'
      end

      it "should return nothing if response does not have error message node" do
        net_http_response = Net::HTTPNotFound.new('1.1', 404, 'Not Found')
        net_http_response.stub(:body).and_return('<html><body>Not Found</body></html>')
        response = HTTParty::Response.new(HTTParty::Request.new(Net::HTTP::Get, '/'), net_http_response, lambda{ {}})
        error = RightSignature::ResponseError.new(response)
        error.detailed_message.should be_nil
      end
    end

    describe "common_solutions" do
      describe "on 406" do
        it "should suggest to check Content-Type header, url, or Accept header" do
          net_http_response = Net::HTTPNotAcceptable.new('1.1', '406', 'Not Acceptable')
          net_http_response.stub(:body =>"{}")
          response = HTTParty::Response.new(HTTParty::Request.new(Net::HTTP::Get, '/'), net_http_response, lambda { {} })
          error = RightSignature::ResponseError.new(response)
          error.common_solutions.should match /Check the Content-Type/i
          error.common_solutions.should match /ensure url has \.xml or \.json/i
          error.common_solutions.should match /check 'Accept' header/i
        end
      end

      describe "on 401" do
        it "should suggest to check credentials" do
          net_http_response = Net::HTTPUnauthorized.new('1.1', '401', 'Unauthorized Access')
          net_http_response.stub(:body =>"{}")
          response = HTTParty::Response.new(HTTParty::Request.new(Net::HTTP::Get, '/'), net_http_response, lambda { {} })
          error = RightSignature::ResponseError.new(response)
          error.common_solutions.should match /Check your credentials/i
        end
      end

      describe "on 500s" do
        it "should suggest to check xml or json format" do
          net_http_response = Net::HTTPInternalServerError.new('1.1', '500', 'Internal Server Error')
          net_http_response.stub(:body =>"{}")
          response = HTTParty::Response.new(HTTParty::Request.new(Net::HTTP::Get, '/'), net_http_response, lambda { {} })
          error = RightSignature::ResponseError.new(response)
          error.common_solutions.should match /Check the format of your xml or json/i
        end
      end
    end
  end
end
