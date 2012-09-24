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
      
      def get(url, params={}, headers={})
        RightSignature::check_credentials
        
        if RightSignature::has_api_token?
          options = {}
          options[:headers] = headers
          options[:query] = params
          RightSignature::TokenConnection.request(:get, url, options).parsed_response
        else
          unless params.empty?
            url = "#{url}?#{params.sort.map{|param| URI.escape("#{param[0]}=#{param[1]}")}.join('&')}"
          end
          res = RightSignature::OauthConnection.request(:get, url, headers)
          MultiXml.parse(res.body)
        end
      end

      def post(url, body={}, headers={})
        RightSignature::check_credentials
        
        if RightSignature::has_api_token?
          options = {}
          options[:headers] = headers
          options[:body] = XmlFu.xml(body)
          res = RightSignature::TokenConnection.request(:post, url, options)

          unless res.success?
            puts res.body
            raise RightSignature::ResponseError.new(res)
          end

          res.parsed_response
        else
          res = RightSignature::OauthConnection.request(:post, url, XmlFu.xml(body), headers)

          unless res.is_a? Net::HTTPSuccess
            puts res.body
            raise RightSignature::ResponseError.new(res)
          end

          MultiXml.parse(res.body)
        end
      end
    end
    
  end
end