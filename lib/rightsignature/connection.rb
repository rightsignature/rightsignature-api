module RightSignature
  class Connection
    include RightSignature::Document
    include RightSignature::Account
    include RightSignature::Template

    attr_accessor :configuration
    attr_accessor :oauth_connection
    attr_accessor :token_connection

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

    def check_credentials
      raise "Please set load_configuration with #{RightSignature::Connection.api_token_keys.join(',')} or #{RightSignature::Connection.oauth_keys.join(',')}" unless has_api_token? || has_oauth_credentials?
    end

    def has_api_token?
      return false if @configuration.nil?
      RightSignature::Connection.api_token_keys.each do |key|
        return false if @configuration[key].nil? || @configuration[key].match(/^\s*$/)
      end

      return true
    end

    def has_oauth_credentials?
      return false if @configuration.nil?
      RightSignature::Connection.oauth_keys.each do |key| 
        return false if @configuration[key].nil? || @configuration[key].match(/^\s*$/)
      end

      return true
    end

    def self.oauth_keys
      [:consumer_key, :consumer_secret, :access_token, :access_secret].freeze
    end

    def self.api_token_keys
      [:api_token].freeze
    end    
    
    def site
      if has_api_token?
        RightSignature::TokenConnection.base_uri
      else
        @oauth_connection.oauth_consumer.site
      end
    end

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

    def delete(url, headers={})
      if has_api_token?
        options = {}
        options[:headers] = headers

        parse_response(@token_connection.request(:delete, url, options))
      else
        parse_response(@oauth_connection.request(:delete, url, headers))
      end
    end

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
    
    def parse_response(response)
      if response.is_a? Net::HTTPResponse
        unless response.is_a? Net::HTTPSuccess
          puts response.body
          raise RightSignature::ResponseError.new(response)
        end

        MultiXml.parse(response.body)
      else
        unless response.success?
          puts response.body
          raise RightSignature::ResponseError.new(response)
        end
        
        response.parsed_response
      end
    end
    
  end
end