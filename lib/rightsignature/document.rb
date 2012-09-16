module RightSignature
  class Document
    class << self
      def list(options)
        res = RightSignature::Connection.get "/documents.xml"
        res.parsed_response
      end
      
      def details(guid)
        res = RightSignature::Connection.get "/documents/#{guid}.xml"
        res.parsed_response
      end
      
      def batch_details(guids)
        res = RightSignature::Connection.get "/documents/#{guids.join(',')}/batch_details.xml"
        res.parsed_response
      end
      
      def resend_reminder(guid)
        res = RightSignature::Connection.post "/documents/#{guid}/send_reminders.xml", {}
        res.parsed_response
      end
      
      def trash(guid)
        res = RightSignature::Connection.post "/documents/#{guid}/trash.xml", {}
        res.parsed_response
      end

      def extend_expiration(guid)
        res = RightSignature::Connection.post "/documents/#{guid}/extend_expiration.xml", {}
        res.parsed_response
      end
      
      # This will REPLACE the tags on a document
      # tags are an array of {:name => 'tag_name'} or {:name => 'tag_name', :value => 'value'}
      # Hash style:
      # {:name => value}
      def update_tags(guid, tags)
        res = RightSignature::Connection.post "/documents/#{guid}/update_tags.xml", { :tags => tags.map{|t| {:tag => t}} }
        res.parsed_response
      end
      
      # Creates a document from a base64 encoded file or publicly available URL
      # Use strings for hash keys with underscores because Gyoku camelcases underscored keys
      # Ex. of document_hash
      # {
      #   :document => {
      #     :subject => 'My Subject',
      #     'document_data' => {:type => 'base64', :filename => "originalfile.pdf", :value => "mOio90cv"},
      #     'recipients' => [
      #       {:recipient => {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'}},
      #       {:recipient => {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'}},
      #       {:recipient => {'is_sender' => true, :role => 'signer'}},
      #     ],
      #     :tags => [{:tag => {:name => 'sent_from_api'}}, {:tag => {:name => 'user_id', :value => '12345'}}],
      #     :expires_in => '5 days',
      #     :action => "redirect",
      #     'callback_location' => "http://example.com/doc_callback",
      #     'use_text_tags' => false
      #   }
      # }
      def send(document_hash)
        res = RightSignature::Connection.post "/documents.xml", document_hash
        res.parsed_response
      end
      
    end
  end
end