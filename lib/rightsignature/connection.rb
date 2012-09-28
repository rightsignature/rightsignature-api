module RightSignature
  class Connection
    class << self
      def site
        if RightSignature::has_api_token?
          RightSignature::TokenConnection.base_uri
        else
          RightSignature::OauthConnection.oauth_consumer.site
        end
      end

      def put(url, body={}, headers={})
        if RightSignature::has_api_token?
          options = {}
          options[:headers] = headers
          options[:body] = XmlFu.xml(body)
          
          parse_response(RightSignature::TokenConnection.request(:put, url, options))
        else
          parse_response(RightSignature::OauthConnection.request(:put, url, XmlFu.xml(body), headers))
        end
      end

      def delete(url, headers={})
        if RightSignature::has_api_token?
          options = {}
          options[:headers] = headers

          parse_response(RightSignature::TokenConnection.request(:delete, url, options))
        else
          parse_response(RightSignature::OauthConnection.request(:delete, url, headers))
        end
      end

      def get(url, params={}, headers={})
        RightSignature::check_credentials
        
        if RightSignature::has_api_token?
          options = {}
          options[:headers] = headers
          options[:query] = params
          parse_response(RightSignature::TokenConnection.request(:get, url, options))
        else
          unless params.empty?
            url = "#{url}?#{params.sort.map{|param| URI.escape("#{param[0]}=#{param[1]}")}.join('&')}"
          end
          parse_response(RightSignature::OauthConnection.request(:get, url, headers))
        end
      end

      def post(url, body={}, headers={})
        RightSignature::check_credentials
        
        if RightSignature::has_api_token?
          options = {}
          options[:headers] = headers
          options[:body] = XmlFu.xml(body)
          parse_response(RightSignature::TokenConnection.request(:post, url, options))
        else
          parse_response(RightSignature::OauthConnection.request(:post, url, XmlFu.xml(body), headers))
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
end