module RightSignature
  class ResponseError < Exception
    attr_reader :response

    def initialize(response, message=nil)
      self.set_backtrace(caller[1..-1]) if self.backtrace.nil?
      @response = response
      super((message || @response.message))
    end

    def code
      @response.code
    end
  
    def common_solutions
      if @response.code.to_i == 406
        "Check the Content-Type and makes sure it's the correct type (usually application/json or application/xml), ensure url has .xml or .json at the end, check 'Accept' header to allow xml or json ('*/*' for anything)"
      elsif @response.code.to_i  == 401
        "Check your credentials and make sure they are correct and not expired"
      elsif @response.code.to_i  >= 500 && @response.code.to_i  < 600
        "Check the format of your xml or json"
      end
    end
  end

  class TokenResponseError < Exception; end
  class OAuthResponseError < Exception; end
end
