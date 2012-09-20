module RightSignature
  class Document
    extend RightSignature::Helpers

    class << self
      
      def list(options={})
        options[:tags] = TagsHelper.mixed_array_to_string_array(options[:tags]) if options[:tags]
        options[:state] = options[:state].join(',') if options[:state] && options[:state].is_a?(Array)
        RightSignature::Connection.get "/api/documents.xml", options
      end
      
      def details(guid)
        RightSignature::Connection.get "/api/documents/#{guid}.xml"
      end
      
      def batch_details(guids)
        RightSignature::Connection.get "/api/documents/#{guids.join(',')}/batch_details.xml"
      end
      
      def send_reminder(guid)
        RightSignature::Connection.post "/api/documents/#{guid}/send_reminders.xml", {}
      end
      
      def trash(guid)
        RightSignature::Connection.post "/api/documents/#{guid}/trash.xml", {}
      end

      def extend_expiration(guid)
        RightSignature::Connection.post "/api/documents/#{guid}/extend_expiration.xml", {}
      end
      
      # This will REPLACE the tags on a document
      # tags are an array of 'tag_name' or {'tag_name' => 'value'}
      # Hash style:
      # {:name => value}
      def update_tags(guid, tags)
        RightSignature::Connection.post "/api/documents/#{guid}/update_tags.xml", { :tags => TagsHelper.array_to_xml_hash(tags) }
      end
      
      # Creates a document from a base64 encoded file or publicly available URL
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
      def send_document(document_hash)
        RightSignature::Connection.post "/api/documents.xml", document_hash
      end
      
    end
  end
end