module RightSignature
  class TokenConnection
    include HTTParty
    base_uri 'https://rightsignature.com/api'
    format :xml

    class <<self
      def request(method, url, options)
        options[:headers] ||= {}
        options[:headers]['api-token'] = RightSignature::configuration[:api_token]
        options[:headers]["Accept"] ||= "*/*"
        options[:headers]["content-type"] ||= "application/xml"
        __send__(method, url, options)
      end
      
    end

  end
end