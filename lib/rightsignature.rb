require 'httparty'
require 'xml-fu'
require 'oauth'
require 'rightsignature/errors'
require 'rightsignature/helpers/normalizing'
require 'rightsignature/document'
require 'rightsignature/template'
require 'rightsignature/connection/oauth_connection'
require 'rightsignature/connection/token_connection'
require 'rightsignature/connection'

XmlFu::Node.symbol_conversion_algorithm = :none

module RightSignature
  class <<self
    attr_accessor :configuration
    
    def load_configuration(creds={})
      @configuration = {}
      oauth_keys.each do |key|
        @configuration[key] = creds[key].to_s
      end

      api_token_keys.each do |key|
        @configuration[key] = creds[key].to_s
      end
      
      @configuration
    end
    
    def check_credentials
      raise "Please set load_configuration with #{api_token_keys.join(',')} or #{oauth_keys.join(',')}" unless has_api_token? || has_oauth_credentials?
    end
    
    def has_api_token?
      return false if @configuration.nil?
      api_token_keys.each do |key|
        return false if @configuration[key].nil? || @configuration[key].match(/^\s*$/)
      end
      
      return true
    end
    
    def has_oauth_credentials?
      return false if @configuration.nil?
      oauth_keys.each do |key| 
        return false if @configuration[key].nil? || @configuration[key].match(/^\s*$/)
      end
      
      return true
    end
    
  private
    def oauth_keys
      [:consumer_key, :consumer_secret, :access_token, :access_secret].freeze
    end

    def api_token_keys
      [:api_token].freeze
    end
  end
end