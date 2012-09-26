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
      
      # Creates a document from a raw data
      # * file: file binary. Ex. File.read('myfile.pdf')
      # * filename: original filename
      # * subject: subject of the document that'll appear in email
      # * recipients: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer'). 
      #     An optional :is_sender (true/false) is used to referrence the API User and won't need to supply :name and :email
      #     Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
      #     [
      #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
      #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
      #       {'is_sender' => true, :role => 'signer'},
      #     ]
      # * options: other optional values
      #     - description: document description that'll appear in the email
      #     - action: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
      #         Ex. ['sent_from_api', {"user_id" => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      #     - use_text_tags: Document has special Text Tags that RightSignature parse. true or false.
      #         More info: https://rightsignature.com/apidocs/text_tags
      def send_document_from_data(file_data, filename, subject, recipients, options={})
        send_document(subject, recipients, {:type => "base64", :filename => filename, :value => Base64::encode64(file_data)}, options)
      end
      
      # Creates a document from a File or path to file
      # * file: Path to file or File object
      # * subject: subject of the document that'll appear in email
      # * recipients: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer'). 
      #     An optional :is_sender (true/false) is used to referrence the API User and won't need to supply :name and :email
      #     Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
      #     [
      #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
      #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
      #       {'is_sender' => true, :role => 'signer'},
      #     ]
      # * options: other optional values
      #     - description: document description that'll appear in the email
      #     - action: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
      #         Ex. ['sent_from_api', {"user_id" => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      #     - use_text_tags: Document has special Text Tags that RightSignature parse. true or false.
      #         More info: https://rightsignature.com/apidocs/text_tags
      def send_document_from_file(file, subject, recipients, options={})
        send_document(subject, recipients, {:type => "base64", :filename => File.basename(file), :value => Base64::encode64(File.read(file)) }, options)
      end
      
      # Creates a document from URL
      # * url: URL to file
      # * subject: subject of the document that'll appear in email
      # * recipients: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer'). 
      #     An optional :is_sender (true/false) is used to referrence the API User and won't need to supply :name and :email
      #     Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
      #     [
      #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
      #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
      #       {'is_sender' => true, :role => 'signer'},
      #     ]
      # * options: other optional values
      #     - description: document description that'll appear in the email
      #     - action: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
      #         Ex. ['sent_from_api', {"user_id" => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      #     - use_text_tags: Document has special Text Tags that RightSignature parse. true or false.
      #         More info: https://rightsignature.com/apidocs/text_tags
      def send_document_from_url(url, subject, recipients, options={})
        send_document(subject, recipients, {:type => "url", :filename => File.basename(url), :value => url }, options)
      end
      
      # Creates a document from a base64 encoded file or publicly available URL
      # * document_data: hash of document source :type ('base64' or 'url'), :filename to be used, :value of source (url or base64 encoded binary)
      # * subject: subject of the document that'll appear in email
      # * recipients: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer'). 
      #     An optional :is_sender (true/false) is used to referrence the API User and won't need to supply :name and :email
      #     Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
      #     [
      #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
      #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
      #       {'is_sender' => true, :role => 'signer'},
      #     ]
      # * options: other optional values
      #     - description: document description that'll appear in the email
      #     - action: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
      #         Ex. ['sent_from_api', {"user_id" => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      #     - use_text_tags: Document has special Text Tags that RightSignature parse. true or false.
      #         More info: https://rightsignature.com/apidocs/text_tags
      # Ex. 
      # recipients = [
      #   {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
      #   {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
      #   {'is_sender' => true, :role => 'signer'},
      # ]
      # document_data = {:type => 'base64', :filename => "originalfile.pdf", :value => Base64.encode64(File.read('myfile.pdf','r'))}
      # options = {
      #   :tags => ['sent_from_api', 'user_id' => '12345'],
      #   :expires_in => '5 days',
      #   :action => "redirect",
      #   'callback_location' => "http://example.com/doc_callback",
      #   'use_text_tags' => false
      # }
      # RightSignature::send_document( "My Subject", recipients, document_data, options)
      # 
      def send_document(subject, recipients, document_data, options={})
        document_hash = {:document => {
          :subject => subject,
          :action => "send",
          :document_data => document_data
        }}
        
        document_hash[:document][:recipients] = []
        recipients.each do |recipient_hash|
          document_hash[:document][:recipients] << { :recipient => recipient_hash}
        end
        
        document_hash[:document].merge!(options)
        RightSignature::Connection.post "/api/documents.xml", document_hash
      end
      
      # Prefills a document from a base64 encoded file or publicly available URL and returns a url that allows someone to send as the API User
      # * document_data: hash of document source :type ('base64' or 'url'), :filename to be used, :value of source (url or base64 encoded binary)
      # * subject: subject of the document that'll appear in email
      # * recipients: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer'). 
      #     An optional :is_sender (true/false) is used to referrence the API User and won't need to supply :name and :email
      #     Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
      #     [
      #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
      #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
      #       {'is_sender' => true, :role => 'signer'},
      #     ]
      # * options: other optional values
      #     - description: document description that'll appear in the email
      #     - action: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
      #         Ex. ['sent_from_api', {"user_id" => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      #     - use_text_tags: Document has special Text Tags that RightSignature parse. true or false.
      #         More info: https://rightsignature.com/apidocs/text_tags
      # Ex. 
      # recipients = [
      #   {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
      #   {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
      #   {'is_sender' => true, :role => 'signer'},
      # ]
      # document_data = {:type => 'base64', :filename => "originalfile.pdf", :value => Base64.encode64(File.read('myfile.pdf','r'))}
      # options = {
      #   :tags => ['sent_from_api', 'user_id' => '12345'],
      #   :expires_in => '5 days',
      #   :action => "redirect",
      #   'callback_location' => "http://example.com/doc_callback",
      #   'use_text_tags' => false
      # }
      # RightSignature::generate_document_redirect_url( "My Subject", recipients, document_data, options)
      #
      def generate_document_redirect_url(subject, recipients, document_data, options={})
        options[:action] = "redirect"
        response = send_document(subject, recipients, document_data, options)
        
        "#{RightSignature::Connection.site}/builder/new?rt=#{response['document']['redirect_token']}"
      end
      
      def get_signer_links_for(guid, redirect_location = nil)
        params = {}
        params[:redirect_location] = URI.encode(redirect_location) if redirect_location
        response = RightSignature::Connection.get "/api/documents/#{guid}/signer_links.xml", params
        
        signer_links = []
        
        if response["document"]["signer_links"]["signer_link"].is_a? Array
          response["document"]["signer_links"]["signer_link"].each do |signer_link|
            signer_links << {"name" => signer_link["name"], "url" => "#{RightSignature::Connection.site}/signatures/embedded?rt=#{signer_link["signer_token"]}"}
          end
        else
          signer_link = response["document"]["signer_links"]["signer_link"]
          signer_links << {"name" => signer_link["name"], "url" => "#{RightSignature::Connection.site}/signatures/embedded?rt=#{signer_link["signer_token"]}"}
        end
        signer_links
      end
      
    end
  end
end