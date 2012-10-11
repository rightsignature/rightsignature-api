module RightSignature
  class TokenConnection
    include HTTParty
    base_uri 'https://rightsignature.com'
    format :xml
    
    attr_reader :api_token

    def initialize(api_token)
      @api_token = api_token
    end
    

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