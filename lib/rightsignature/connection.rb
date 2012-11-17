module RightSignature
  class Connection
    include RightSignature::Document
    include RightSignature::Account
    include RightSignature::Template

    attr_accessor :configuration
    attr_accessor :oauth_connection
    attr_accessor :token_connection

    # Creates new instance of RightSignature::Connection to make API calls
    # * <b>creds</b>: Hash of credentials for API Token or OAuth. If both are specified, it uses API Token
    #   * Hash key for API Token:
    #     * :api_token
    #   * Hash keys for OAuth:
    #     * :consumer_key
    #     * :consumer_secret
    #     * :access_token
    #     * :access_secret
    #     
    # Example for Api Token:
    #   @rs_connection = RightSignature::Connection.new(:api_token => "MYTOKEN")
    # 
    # Example for OAuth:
    #   @rs_connection = RightSignature::Connection.new(:consumer_key => "ckey", :consumer_secret => "csecret", :access_token => "atoken", :access_secret => "asecret")
    # 
    def initialize(creds={})
      @configuration = {}
      RightSignature::Connection.oauth_keys.each do |key|
        @configuration[key] = creds[key].to_s
      end

      RightSignature::Connection.api_token_keys.each do |key|
        @configuration[key] = creds[key].to_s
      end

      @token_connection = RightSignature::TokenConnection.new(*RightSignature::Connection.api_token_keys.map{|k| @configuration[k]})
      @oauth_connection = RightSignature::OauthConnection.new(@configuration)

      @configuration
    end

    # Checks if credentials are set for either API Token or for OAuth 
    # 
    def check_credentials
      raise "Please set load_configuration with #{RightSignature::Connection.api_token_keys.join(',')} or #{RightSignature::Connection.oauth_keys.join(',')}" unless has_api_token? || has_oauth_credentials?
    end

    # Checks if API Token credentials are set. Does not validate creds with server.
    # 
    def has_api_token?
      return false if @configuration.nil?
      RightSignature::Connection.api_token_keys.each do |key|
        return false if @configuration[key].nil? || @configuration[key].match(/^\s*$/)
      end

      return true
    end

    # Checks if OAuth credentials are set. Does not validate creds with server.
    # 
    def has_oauth_credentials?
      return false if @configuration.nil?
      RightSignature::Connection.oauth_keys.each do |key| 
        return false if @configuration[key].nil? || @configuration[key].match(/^\s*$/)
      end

      return true
    end

    # :nodoc:
    def self.oauth_keys
      [:consumer_key, :consumer_secret, :access_token, :access_secret].freeze
    end

    # :nodoc:
    def self.api_token_keys
      [:api_token].freeze
    end    
    
    # :nodoc:
    def site
      if has_api_token?
        RightSignature::TokenConnection.base_uri
      else
        @oauth_connection.oauth_consumer.site
      end
    end

    # PUT request to server
    # 
    # Arguments:
    #   url: Path of API call
    #   body: XML body in hash format
    #   url: Hash of HTTP headers to include
    # 
    # Example:
    #   @rs_connection.put("/api/documents.xml", {:documents=> {}}, {"User-Agent" => "My Own"})
    # 
    def put(url, body={}, headers={})
      if has_api_token?
        options = {}
        options[:headers] = headers
        options[:body] = XmlFu.xml(body)
        
        parse_response(@token_connection.request(:put, url, options))
      else
        parse_response(@oauth_connection.request(:put, url, XmlFu.xml(body), headers))
      end
    end

    # DELETE request to server
    # 
    # Arguments:
    #   url: Path of API call
    #   url: Hash of HTTP headers to include
    # 
    # Example:
    #   @rs_connection.delete("/api/users.xml", {"User-Agent" => "My Own"})
    # 
    def delete(url, headers={})
      if has_api_token?
        options = {}
        options[:headers] = headers

        parse_response(@token_connection.request(:delete, url, options))
      else
        parse_response(@oauth_connection.request(:delete, url, headers))
      end
    end

    # GET request to server
    # 
    # Arguments:
    #   url: Path of API call
    #   params: Hash of URL parameters to include in request
    #   url: Hash of HTTP headers to include
    # 
    # Example:
    #   @rs_connection.get("/api/documents.xml", {:search => "my term"}, {"User-Agent" => "My Own"})
    # 
    def get(url, params={}, headers={})
      check_credentials
      
      if has_api_token?
        options = {}
        options[:headers] = headers
        options[:query] = params
        parse_response(@token_connection.request(:get, url, options))
      else
        unless params.empty?
          url = "#{url}?#{params.sort.map{|param| URI.escape("#{param[0]}=#{param[1]}")}.join('&')}"
        end
        parse_response(@oauth_connection.request(:get, url, headers))
      end
    end

    # POST request to server
    # 
    # Arguments:
    #   url: Path of API call
    #   url: Hash of HTTP headers to include
    # 
    # Example:
    #   @rs_connection.post("/api/users.xml", {"User-Agent" => "My Own"})
    # 
    def post(url, body={}, headers={})
      check_credentials
      
      if has_api_token?
        options = {}
        options[:headers] = headers
        options[:body] = XmlFu.xml(body)
        parse_response(@token_connection.request(:post, url, options))
      else
        parse_response(@oauth_connection.request(:post, url, XmlFu.xml(body), headers))
      end
    end
    
    # Attempts to parse response from a connection and return it as a hash. 
    # If response isn't a success, an RightSignature::ResponseError is raised
    # 
    # Arguments:
    #   url: Path of API call
    #   url: Hash of HTTP headers to include
    # 
    # Example:
    #   @rs_connection.delete("/api/users.xml", {"User-Agent" => "My Own"})
    # 
    def parse_response(response)
      if response.is_a? Net::HTTPResponse
        unless response.is_a? Net::HTTPSuccess
          puts response.body
          msg = nil
          begin
            msg = MultiXml.parse(response.body)["error"]["message"]
          rescue
          end
          raise RightSignature::ResponseError.new(response, msg)
        end

        MultiXml.parse(response.body)
      else
        unless response.success?
          puts response.body
          msg = nil
          begin
            msg = MultiXml.parse(response.body)["error"]["message"]
          rescue
          end
          raise RightSignature::ResponseError.new(response, msg)
        end
        
        response.parsed_response
      end
    end
    
  end
end