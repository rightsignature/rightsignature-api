module RightSignature
  class OauthConnection
    attr_reader :request_token
    attr_reader :consumer_key, :consumer_secret, :oauth_access_token, :oauth_access_secret

    # Creates new instance of RightSignature::OauthConnection to make API calls
    # * <b>creds</b>: Hash of credentials for OAuth. 
    #   * Hash keys for OAuth:
    #     * :consumer_key
    #     * :consumer_secret
    #     * :access_token
    #     * :access_secret
    #     
    # Example:
    #   @rs_oauth = RightSignature::OauthConnection.new(:consumer_key => "ckey", :consumer_secret => "csecret", :access_token => "atoken", :access_secret => "asecret")
    # 
    def initialize(credentials={})
      @consumer_key = credentials[:consumer_key]
      @consumer_secret = credentials[:consumer_secret]
      @oauth_access_token = credentials[:access_token]
      @oauth_access_secret = credentials[:access_secret]
    end
    
    # Oauth consumer
    def oauth_consumer
      check_credentials unless @consumer_key && @consumer_secret
      @oauth_consumer ||= OAuth::Consumer.new(
        @consumer_key,
        @consumer_secret,
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
    
    # Access token
    def access_token
      check_credentials
      @access_token ||= OAuth::AccessToken.new(oauth_consumer,  @oauth_access_token,  @oauth_access_secret)
    end

    # Replaces access token 
    # * <b>access_token</b>: access token key
    # * <b>access_secret</b>: access token secret
    # 
    def set_access_token(access_token, access_secret)
      @oauth_access_token = access_token
      @oauth_access_secret = access_secret
      @access_token = OAuth::AccessToken.new(oauth_consumer, @oauth_access_token, @oauth_access_secret)
    end
    
    # Uses consumer to generate a request token.
    def new_request_token
      @request_token = oauth_consumer.get_request_token
    end
    
    # Uses request token and given OAuth verifier to generate an access token. Requires a request token to be set.
    # * <b>oauth_verifier</b>: OAuth verifier
    # 
    def generate_access_token(oauth_verifier)
      raise "Please set request token with new_request_token" unless @request_token
      @access_token = @request_token.get_access_token(:oauth_verifier =>  oauth_verifier)
      @oauth_access_token = @access_token.token
      @oauth_access_secret = @access_token.secret
      @access_token
    end
    
    # Generates HTTP request with oauth credentials. Require access_token to be set.
    # * <b>method</b>: HTTP Method. Ex. ('get'/'post'/'delete'/'put')
    # * <b>options</b>: OAuth::AccessToken options to pass. Last option should be headers
    # 
    def request(method, *options)
      options.last ||= {}
      options.last["Accept"] ||= "*/*"
      options.last["content-type"] ||= "application/xml"

      self.access_token.__send__(method, *options)
    end
    
  private
    # Raises exception if OAuth credentials are not set.
    def check_credentials
      raise "Please set #{RightSignature::Connection.oauth_keys.join(', ')}" unless has_oauth_credentials?
    end

    # Checks if OAuth credentials are set.
    def has_oauth_credentials?
      [@consumer_key, @consumer_secret, @oauth_access_token, @oauth_access_secret].each do |cred| 
        return false if cred.nil? || cred.match(/^\s*$/)
      end

      true
    end
  end
end