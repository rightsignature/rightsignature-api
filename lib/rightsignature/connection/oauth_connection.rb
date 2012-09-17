module RightSignature
  class OauthConnection

    class << self
      def oauth_consumer
        @oauth_consumer ||= OAuth::Consumer.new(
          RightSignature::configuration[:consumer_key],
          RightSignature::configuration[:consumer_secret],
          {
           :site              => "https://rightsignature.com",
           :scheme            => :header,
           :http_method        => :post,
           :authorize_path    =>'/oauth/authorize', 
           :access_token_path =>'/oauth/access_token', 
           :request_token_path=>'/oauth/request_token'
          }
        )
      end
      
      def access_token
        @access_token ||= OAuth::AccessToken.new(oauth_consumer,  RightSignature::configuration[:access_token],  RightSignature::configuration[:access_secret])
      end
      
      def request(method, path, headers={})
        self.access_token.__send__(method, path, headers)
      end
    end

  end
end