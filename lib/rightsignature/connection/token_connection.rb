module RightSignature
  class TokenConnection
    include HTTParty
    base_uri 'https://rightsignature.com'
    format :xml
    
    attr_reader :api_token

    # Creates new instance of RightSignature::TokenConnection to make API calls
    # * <b>api_token</b>: API Token. 
    #     
    # Example:
    #   @rs_token = RightSignature::TokenConnection.new("APITOKEN")
    # 
    def initialize(api_token)
      @api_token = api_token
    end
    
    # Generates HTTP request with token credentials. Require api_token to be set.
    # * <b>method</b>: HTTP Method. Ex. ('get'/'post'/'delete'/'put')
    # * <b>url</b>: request path/url of request
    # * <b>options</b>: HTTPary options to pass. Last option should be headers
    # 
    def request(method, url, options)
      raise "Please set api_token" if @api_token.nil? || @api_token.empty?
      
      options[:headers] ||= {}
      options[:headers]['api-token'] = @api_token
      options[:headers]["Accept"] ||= "*/*"
      options[:headers]["content-type"] ||= "application/xml"
      __send__(method, url, options)
    end
    
  end

end