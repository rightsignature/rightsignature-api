module RightSignature
  class OauthConnection
    include HTTParty
    base_uri 'https://rightsignature.com/api'
    format :xml

    class << self
      def oauth_client
        @oauth_client ||= OAuth::Consumer.new(
          RightSignature::configuration[:consumer_key],
          RightSignature::configuration[:consumer_secret],
          {
           :site => RightSignature::configuration[:url],
           :authorize_path=>'/oauth/authorize', 
           :access_token_path=>'/oauth/access_token', 
           :request_token_path=>'/oauth/request_token'
          }
        )
      end
      
      def access_token
        @access_token ||= OAuth::AccessToken.new(self.oauth_client,  RightSignature::configuration[:access_token],  RightSignature::configuration[:access_secret])
      end
      
      def get(path, options={})
        self.access_token.get(path, options)
      end

      def post(path, options={})
        self.access_token.post(path, options)
      end
    end

  end
end