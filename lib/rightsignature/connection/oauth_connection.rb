module RightSignature
  class OauthConnection

    class << self
      def oauth_consumer
        check_credentials
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
        check_credentials
        @access_token ||= OAuth::AccessToken.new(oauth_consumer,  RightSignature::configuration[:access_token],  RightSignature::configuration[:access_secret])
      end
      
      def request(method, *options)
        options.last ||= {}
        options.last["Accept"] ||= "*/*"
        options.last["content-type"] ||= "application/xml"

        self.access_token.__send__(method, *options)
      end
      
    private
      def check_credentials
        raise "Please set load_configuration with #{RightSignature::oauth_keys.join(', ')}" unless RightSignature::has_oauth_credentials?
      end
    end

  end
end