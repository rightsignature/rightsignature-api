using RefineHashToIndifferentAccess

module RightSignature
  module Document
    include RightSignature::Helpers

    # Lists documents
    #   * <b>options</b>: (optional) search filters
    #     * <b>:state</b> - (completed/trashed/pending) filter by state
    #     * <b>:page</b> - page offset
    #     * <b>:per_page</b> - # of entries per page to return
    #     * <b>:search</b> - search term filter
    #     * <b>:tags</b> - tags filter. Array of ["single_tag", {"tag_key" => "tag_value"}]
    #     * <b>:sort</> - sort documents by given attribute.
    #     API supports 'created', 'completed', and 'activity'
    #     * <b>:range</b> - ('today'/'thisweek'/'thismonth'/'alltime'/Date) return documents with a certain date range.
    #     * <b> :recipient_email</b> - filter document where it has a recipient with given email and involves the current OAuth user.
    #     * <b> :account</b> - (true/false) include all documents in current account if true.
    #
    # Ex.
    #   options = {
    #     :state => ['completed', 'trashed'],
    #     :page => 1,
    #     :per_page => 20,
    #     :search => "me",
    #     :tags => ["single_tag", "key" => "with_value"]
    #   }
    #
    #   @rs_connection.documents_list(options)
    #
    def documents_list(options={})
      if options[:metadata]
        options[:tags] = TagsHelper.array_and_metadata_to_string_array(options[:tags], options.delete(:metadata))
      elsif options[:tags]
        options[:tags] = TagsHelper.mixed_array_to_string_array(options[:tags])
      end
      options[:state] = options[:state].join(',') if options[:state] && options[:state].is_a?(Array)
      get "/api/documents.xml", options
    end

    # Gets details for a document
    # * <b>guids</b>: Array of document GUIDs
    #
    # Ex. Get details for document GUID123
    #   @rs_connection.document_details("GUID123")
    #
    def document_details(guid)
      get "/api/documents/#{guid}.xml"
    end

    # Gets details for multiple documents.
    # * <b>guids</b>: Array of document GUIDs
    #
    # Ex. Get details for documents GUID123 and GUID345
    #   @rs_connection.documents_batch_details(["GUID123","GUID345"])
    #
    def documents_batch_details(guids)
      get "/api/documents/#{guids.join(',')}/batch_details.xml"
    end

    # Sends a reminder for a document
    # * <b>guid</b>: Document GUID
    #
    # Ex. Sends reminder for document GUID123
    #   @rs_connection.send_reminder("GUID123")
    #
    def send_reminder(guid)
      post "/api/documents/#{guid}/send_reminders.xml", {}
    end

    # Extends a document's expiration date by 7 days
    # * <b>guid</b>: Document GUID
    #
    # Ex. Extend expiration for document GUID123 by 7 days
    #   @rs_connection.trash_document("GUID123")
    #
    def trash_document(guid)
      post "/api/documents/#{guid}/trash.xml", {}
    end


    # Extends a document's expiration date by 7 days
    # * <b>guid</b>: Document GUID
    #
    # Ex. Extend expiration for document GUID123 by 7 days
    #   @rs_connection.extend_document_expiration("GUID123")
    #
    def extend_document_expiration(guid)
      post "/api/documents/#{guid}/extend_expiration.xml", {}
    end

    # <b>REPLACE</b> the tags on a document
    # tags are an array of 'tag_name' or {'tag_name' => 'value'}
    #
    # Ex. Replaces document GUID123 with tags "single_tag", "hello:bye"
    #   @rs_connection.update_document_tags("GUID123", ["single_tag", {"hello" => "bye"}])
    def update_document_tags(guid, tags)
      post "/api/documents/#{guid}/update_tags.xml", { :tags => TagsHelper.array_to_xml_hash(tags) }
    end

    # Creates a document from a raw data
    # * <b>file</b>: file binary. Ex. File.read('myfile.pdf')
    # * <b>filename</b>: original filename
    # * <b>subject</b>: subject of the document that'll appear in email
    # * <b>recipients</b>: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer').
    #   One of the recipients requires <b>:is_sender</b> (true/false) to reference the API User and won't need to supply :name and :email
    #   Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
    #     [
    #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #       {'is_sender' => true, :role => 'signer'},
    #     ]
    # * <b>options</b>: other optional values
    #   - <b>description</b>: document description that'll appear in the email
    #   - <b>action</b>: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
    #   - <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   - <b>tags</b>: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
    #     Ex. ['sent_from_api', {"user_id" => "32"}]
    #   - <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed.
    #     Ex. "http://yoursite/callback"
    #   - <b>use_text_tags</b>: Document has special Text Tags that RightSignature parse. true or false.
    #     More info: https://rightsignature.com/apidocs/text_tags
    def send_document_from_data(file_data, filename, subject, recipients, options={})
      send_document(subject, recipients, {:type => "base64", :filename => filename, :value => Base64::encode64(file_data)}, options)
    end

    # Creates a document from a File or path to file
    # * <b>file</b>: Path to file or File object
    # * <b>subject</b>: subject of the document that'll appear in email
    # * <b>recipients</b>: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer').
    #   One of the recipients requires <b>:is_sender</b> (true/false) to reference the API User and won't need to supply :name and :email
    #   Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
    #     [
    #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #       {'is_sender' => true, :role => 'signer'},
    #     ]
    # * <b>options</b>: other optional values
    #   - <b>description</b>: document description that'll appear in the email
    #   - <b>action</b>: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
    #   - <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   - <b>tags</b>: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
    #       Ex. ['sent_from_api', {"user_id" => "32"}]
    #   - <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed.
    #       Ex. "http://yoursite/callback"
    #   - <b>use_text_tags</b>: Document has special Text Tags that RightSignature parse. true or false.
    #       More info: https://rightsignature.com/apidocs/text_tags
    #
    # Example:
    #   recipients = [
    #     {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #     {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #     {'is_sender' => true, :role => 'signer'}
    #   ]
    #   options={
    #     :tags => [{:tag => {:name => 'sent_from_api'}}, {:tag => {:name => 'user_id', :value => '12345'}}],
    #     :expires_in => '5 days',
    #     :action => "redirect",
    #     'callback_location' => "http://example.com/doc_callback",
    #     'use_text_tags' => false
    #   }
    #   @rs_connection.send_document_from_file("here/is/myfile.pdf", 'My Subject', recipients, options)
    #
    def send_document_from_file(file, subject, recipients, options={})
      send_document(subject, recipients, {:type => "base64", :filename => File.basename(file), :value => Base64::encode64(File.read(file)) }, options)
    end

    # Creates a document from URL
    # * <b>url</b>: URL to file
    # * <b>subject</b>: subject of the document that'll appear in email
    # * <b>recipients</b>: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer').
    #   One of the recipients requires <b>:is_sender</b> (true/false) to reference the API User and won't need to supply :name and :email
    #   Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
    #     [
    #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #       {'is_sender' => true, :role => 'signer'},
    #     ]
    # * <b>options</b>: other optional values
    #   - <b>description</b>: document description that'll appear in the email
    #   - <b>action</b>: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
    #   - <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   - <b>tags</b>: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
    #       Ex. ['sent_from_api', {"user_id" => "32"}]
    #   - <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed.
    #       Ex. "http://yoursite/callback"
    #   - <b>use_text_tags</b>: Document has special Text Tags that RightSignature parse. true or false.
    #       More info: https://rightsignature.com/apidocs/text_tags
    #
    # Example:
    #   recipients = [
    #     {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #     {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #     {'is_sender' => true, :role => 'signer'}
    #   ]
    #   options={
    #     :tags => [{:tag => {:name => 'sent_from_api'}}, {:tag => {:name => 'user_id', :value => '12345'}}],
    #     :expires_in => '5 days',
    #     :action => "redirect",
    #     'callback_location' => "http://example.com/doc_callback",
    #     'use_text_tags' => false
    #   }
    #   @rs_connection.send_document_from_url("http://myfile/here", 'My Subject', recipients, options)
    #
    def send_document_from_url(url, subject, recipients, options={})
      send_document(subject, recipients, {:type => "url", :filename => File.basename(url), :value => url }, options)
    end

    # Creates a document from a base64 encoded file or publicly available URL
    # * <b>document_data</b>: hash of document source :type ('base64' or 'url'), :filename to be used, :value of source (url or base64 encoded binary)
    # * <b>subject</b>: subject of the document that'll appear in email
    # * <b>recipients</b>: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer').
    #   One of the recipients requires <b>:is_sender</b> (true/false) to reference the API User and won't need to supply :name and :email
    #   Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
    #     [
    #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #       {'is_sender' => true, :role => 'signer'},
    #     ]
    # * options: other optional values
    #   - <b>description</b>: document description that'll appear in the email
    #   - <b>action</b>: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
    #   - <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   - <b>tags</b>: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
    #       Ex. ['sent_from_api', {"user_id" => "32"}]
    #   - <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed.
    #       Ex. "http://yoursite/callback"
    #   - <b>use_text_tags</b>: Document has special Text Tags that RightSignature parse. true or false.
    #       More info: https://rightsignature.com/apidocs/text_tags
    # Ex.
    #   recipients = [
    #     {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #     {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #     {'is_sender' => true, :role => 'signer'},
    #   ]
    #   document_data = {:type => 'base64', :filename => "originalfile.pdf", :value => Base64.encode64(File.read('myfile.pdf','r'))}
    #   options = {
    #     :tags => ['sent_from_api', 'user_id' => '12345'],
    #     :expires_in => '5 days',
    #     :action => "redirect",
    #     'callback_location' => "http://example.com/doc_callback",
    #     'use_text_tags' => false
    #   }
    #   @rs_connection.send_document( "My Subject", recipients, document_data, options)
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
      post "/api/documents.xml", document_hash
    end

    # Prefills a document from a base64 encoded file or publicly available URL and returns a url that allows someone to send as the API User
    # * <b>document_data</b>: hash of document source :type ('base64' or 'url'), :filename to be used, :value of source (url or base64 encoded binary)
    # * <b>subject</b>: subject of the document that'll appear in email
    # * <b>recipients</b>: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer').
    #   One of the recipients requires <b>:is_sender</b> (true/false) to reference the API User and won't need to supply :name and :email
    #   Ex. CC to support@rightsignature.com, with sender and john@rightsignature.com as a signer
    #     [
    #       {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #       {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #       {'is_sender' => true, :role => 'signer'},
    #     ]
    # * <b>options</b>: other optional values
    #   - <b>description</b>: document description that'll appear in the email
    #   - <b>action</b>: 'send' or 'redirect'. Redirect will return a token that will allow another person to send the document under API user's account
    #   - <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   - <b>tags</b>: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
    #     Ex. ['sent_from_api', {"user_id" => "32"}]
    #   - <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed.
    #     Ex. "http://yoursite/callback"
    #   - <b>use_text_tags</b>: Document has special Text Tags that RightSignature parse. true or false.
    #     More info: https://rightsignature.com/apidocs/text_tags
    # Ex.
    #   recipients = [
    #     {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
    #     {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
    #     {'is_sender' => true, :role => 'signer'},
    #   ]
    #   document_data = {:type => 'base64', :filename => "originalfile.pdf", :value => Base64.encode64(File.read('myfile.pdf','r'))}
    #   options = {
    #     :tags => ['sent_from_api', 'user_id' => '12345'],
    #     :expires_in => '5 days',
    #     :action => "redirect",
    #     'callback_location' => "http://example.com/doc_callback",
    #     'use_text_tags' => false
    #   }
    #   @rs_connection.generate_document_redirect_url( "My Subject", recipients, document_data, options)
    #
    def generate_document_redirect_url(subject, recipients, document_data, options={})
      options[:action] = "redirect"
      response = send_document(subject, recipients, document_data, options)

      "#{site}/builder/new?rt=#{response['document']['redirect_token']}"
    end

    # Generates signer links for a Document with signers with email of "noemail@rightsignature.com"
    # * <b>guid</b>: Document GUID
    # * <b>redirect_location</b>: (Optional) URL to redirect each signer after it is completed
    #
    # Ex. Generate signer links for document GUID123 that redirects users to http://mysite/done_signing after signing
    #   @rs_connection.get_document_signer_links_for("GUID123", "http://mysite/done_signing")
    #
    # Note that ONLY recipients with an email of "noemail@rightsignature.com" will have a signer link
    def get_document_signer_links_for(guid, redirect_location = nil)
      params = {}
      params[:redirect_location] = URI.encode(redirect_location) if redirect_location
      response = get "/api/documents/#{guid}/signer_links.xml", params

      signer_links = []

      if response["document"]["signer_links"] && response["document"]["signer_links"]["signer_link"].is_a?(Array)
        response["document"]["signer_links"]["signer_link"].each do |signer_link|
          signer_links << {"name" => signer_link["name"], "url" => "#{site}/signatures/embedded?rt=#{signer_link["signer_token"]}"}
        end
      elsif response["document"]["signer_links"]
        signer_link = response["document"]["signer_links"]["signer_link"]
        signer_links << {"name" => signer_link["name"], "url" => "#{site}/signatures/embedded?rt=#{signer_link["signer_token"]}"}
      end
      signer_links
    end

  end
end
