module RightSignature
  class ResponseError < Exception
    attr_reader :response

    # Creates new instance of RightSignature::ResponseError to make API calls
    # * <b>response</b>: Net::HTTP response or HTTParty response
    # * <b>message</b>: (Optional) Custom error message
    #     
    def initialize(response, message=nil)
      self.set_backtrace(caller[1..-1]) if self.backtrace.nil?
      @response = response
      super((message || @response.message))
    end

    # returns HTTP Code from response
    def code
      @response.code
    end
  
    # Suggestions on how to resolve a certain error 
    def common_solutions
      if @response.code.to_i == 406
        "Check the Content-Type and makes sure it's the correct type (usually application/json or application/xml), ensure url has .xml or .json at the end, check 'Accept' header to allow xml or json ('*/*' for anything)"
      elsif @response.code.to_i  == 401
        "Check your credentials and make sure they are correct and not expired"
      elsif @response.code.to_i  >= 500 && @response.code.to_i  < 600
        "Check the format of your xml or json"
      end
    end

    # Attempts to parse an error message from the response body
    def detailed_message
      if @response.is_a? Net::HTTPResponse
        parsed_response = MultiXml.parse(@response.body)

        parsed_response["error"]["message"] if parsed_response && parsed_response["error"]
      else
        if @response.parsed_response.is_a? Hash
          @response.parsed_response["error"]["message"] if @response.parsed_response["error"]
        end
      end
    end
    

  end

  class TokenResponseError < ResponseError # :nodoc:
  end
  class OAuthResponseError < ResponseError # :nodoc:
  end
end
