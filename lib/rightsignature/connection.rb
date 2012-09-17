module RightSignature
  class Connection
    class << self
      def get(url, params={}, headers={})
        RightSignature::check_credentials
        
        if RightSignature::has_api_token?
          options = {}
          options[:headers] = headers
          options[:query] = params
          RightSignature::TokenConnection.request(:get, url, options)
        else
          unless params.empty?
            url = "#{url}?#{params.map{|k,v| URI.escape("#{k}=#{v}")}.join('&')}"
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
          options[:body] = Gyoku.xml(body)
          RightSignature::TokenConnection.request(:post, url, options).parsed_response
        else
          res = RightSignature::OauthConnection.request(:post, url, Gyoku.xml(body), headers)
          MultiXml.parse(res.body)
        end
      end
    end
    
  end
end