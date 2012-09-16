module RightSignature
  class Connection
    class << self
      def get(url, params={}, headers={})
        RightSignature::check_credentials
        
        options = {}
        if RightSignature::configuration[:api_token].nil?
          RightSignature::OauthConnection.request(:get, url, options)
        else
          options[:headers] = headers
          options[:query] = params
          RightSignature::TokenConnection.request(:get, url, options)
        end
      end

      def post(url, body={}, headers={})
        RightSignature::check_credentials
        
        options = {}
        if RightSignature::configuration[:api_token].nil?
          RightSignature::OauthConnection.request(:post, url, options)
        else
          options[:headers] = headers
          options[:body] = Gyoku.xml(body)
          RightSignature::TokenConnection.request(:post, url, options)
        end
      end
    end
    
  end
end