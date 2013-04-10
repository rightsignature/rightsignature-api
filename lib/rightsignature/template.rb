module RightSignature
  module Template
    include RightSignature::Helpers
    # List Templates with optional filters
    # * <b>Options</b>: (optional) Hash of filters to use
    #   * <b>page</b>: page number
    #   * <b>per_page</b>: number of templates to return per page. 
    #     API only supports 10, 20, 30, 40, or 50. Default is 10.
    #   * <b>tags</b>: filter templates by given tags. Array of strings, for name/value tags colon (:) should separate name and value.
    #     Ex. "single_tag,tag_key:tag_value" would find templates with 'single_tag' and the name/value of 'tag_key' with value 'tag_value'.
    #   * <b>search</b>: term to search for in templates.
    # 
    # Ex. 
    #   options = {
    #     :state => ['completed', 'trashed'],
    #     :page => 1,
    #     :per_page => 20,
    #     :search => "me",
    #     :tags => ["single_tag", "key" => "with_value"]
    #   }
    #   @rs_connection.templates_list(options)
    def templates_list(options={})
      options[:tags] = TagsHelper.mixed_array_to_string_array(options[:tags]) if options[:tags]
      get "/api/templates.xml", options
    end
    
    # Gets template details
    # * <b>guid</b>: templates guid. Ex. a_1_zcfdidf8fi23
    def template_details(guid)
      get "/api/templates/#{guid}.xml", {}
    end
    
    # Clones a template so it can be used for sending. Always first step in sending a template. 
    # * <b>guid</b>: templates guid. Ex. a_1_zcfdidf8fi23
    def prepackage(guid)
      post "/api/templates/#{guid}/prepackage.xml", {}
    end
    
    # Prefills template. Should use a <b>prepackaged</b> template first.
    # * <b>guid</b>: templates guid. Ex. a_1_zcfdidf8fi23
    # * <b>subject</b>: subject of the document that'll appear in email
    # * <b>roles</b>: Recipients of the document, should be an array of role names and emails in a hash with keys as role_names. 
    #     Ex. [{"Employee" => {:name => "John Employee", :email => "john@employee.com"}}]
    #       is equivalent to 
    #         <role role_name="Employee">
    #           <name>John Employee</name>
    #           <email>john@employee.com</email>
    #         </role>
    # * <b>options</b>: other optional values
    #   * <b>description</b>: document description that'll appear in the email
    #   * <b>merge_fields</b>: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
    #       Ex. [{"Salary" => "$1,000,000"}]
    #         is equivalent to 
    #           <merge_field merge_field_name="Salary">
    #           <value>$1,000,000</value>
    #           </merge_field>
    #   * <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   * <b>tags</b>: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
    #       Ex. ['sent_from_api', {"user_id" => "32"}]
    #   * <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
    #       Ex. "http://yoursite/callback"
    # 
    # Ex. call with all options used
    #   @rs_connection.prefill(
    #     "a_1_zcfdidf8fi23", 
    #     "Your Employee Handbook", 
    #     [{"employee" => {:name => "John Employee", :email => "john@employee.com"}}],
    #     {
    #       :description => "Please read over the handbook and sign it.",
    #       :merge_fields => [
    #         { "Department" => "Fun and games" },
    #         { "Salary" => "$1,000,000" }
    #       ],
    #       :expires_in => 5,
    #       :tags => [
    #         {:name => 'sent_from_api'},
    #         {:name => 'user_id', :value => '32'}
    #       ],
    #       :redirect_location => "http://yoursite/redirect",
    #       :callback_location => "http://yoursite/callback"
    #     })
    def prefill(guid, subject, roles, options={})
      xml_hash = {
        :template => {
          :guid => guid,
          :action => "prefill",
          :subject => subject
        }
      }
      
      xml_hash[:template][:roles] = RolesHelper.array_to_xml_hash(roles)
      
      # Optional arguments
      use_merge_field_ids = options.delete(:use_merge_field_ids)
      xml_hash[:template][:merge_fields] = MergeFieldsHelper.array_to_xml_hash(options[:merge_fields], use_merge_field_ids) if options[:merge_fields]
      xml_hash[:template][:tags] = TagsHelper.array_to_xml_hash(options[:tags]) if options[:tags]
      [:expires_in, :description, :callback_location, :redirect_location, :action, :document_data].each do |other_option|
        xml_hash[:template][other_option] = options[other_option] if options[other_option]
      end

      post "/api/templates.xml", xml_hash
    end
    
    # Prepackages and sends template.
    # * <b>guid</b>: templates guid. Ex. a_1_zcfdidf8fi23
    # * <b>roles</b>: Recipients of the document, should be an array of role names and emails in a hash with keys as role_names. 
    #     Ex. [{"Employee" => {:name => "John Employee", :email => "john@employee.com"}}]
    #       is equivalent to 
    #         <role role_name="Employee">
    #           <name>John Employee</name>
    #           <email>john@employee.com</email>
    #         </role>
    # * <b>options</b>: other optional values
    #   * <b>subject</b>: subject of the document that'll appear in email. Defaults to template's subject
    #   * <b>description</b>: document description that'll appear in the email
    #   * <b>merge_fields</b>: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
    #       Ex. [{"Salary" => "$1,000,000"}]
    #         is equivalent to 
    #           <merge_field merge_field_name="Salary">
    #           <value>$1,000,000</value>
    #           </merge_field>
    #   * <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   * <b>tags</b>: document tags, an array of {:name => 'tag_name'} (for simple tag) or {:name => 'tag_name', :value => 'value'} (for tuples pairs)
    #       Ex. [{:name => 'sent_from_api'}, {:name => "user_id", :value => "32"}]
    #   * <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
    #       Ex. "http://yoursite/callback"
    # 
    # Ex. call with all options used
    #   @rs_connection.prepackage_and_send(
    #     "a_1_zcfdidf8fi23", 
    #     "Your Employee Handbook", 
    #     [{"employee" => {:name => "John Employee", :email => "john@employee.com"}}],
    #     {
    #       :description => "Please read over the handbook and sign it.",
    #       :merge_fields => [
    #         { "Department" => "Fun and games" },
    #         { "Salary" => "$1,000,000" }
    #       ],
    #       :expires_in => 5,
    #       :tags => [
    #         {:name => 'sent_from_api'},
    #         {:name => 'user_id', :value => '32'}
    #       ],
    #       :callback_location => "http://yoursite/callback"
    #     })
    def prepackage_and_send(guid, roles, options={})
      response = prepackage(guid)
      new_guid = response["template"]["guid"]
      send_template(new_guid, options.delete(:subject) || response["template"]["subject"], roles, options)
    end
    
    # Sends template. Should use a <b>prepackaged</b> template first. Easier to use <b>prepackage_and_send</b> for most cases.
    # * <b>guid</b>: templates guid. Ex. a_1_zcfdidf8fi23
    # * <b>subject</b>: subject of the document that'll appear in email
    # * <b>roles</b>: Recipients of the document, should be an array of role names and emails in a hash with keys as role_names. 
    #     Ex. [{"Employee" => {:name => "John Employee", :email => "john@employee.com"}}]
    #       is equivalent to 
    #         <role role_name="Employee">
    #           <name>John Employee</name>
    #           <email>john@employee.com</email>
    #         </role>
    # * <b>options</b>: other optional values
    #   * <b>description</b>: document description that'll appear in the email
    #   * <b>merge_fields</b>: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
    #       Ex. [{"Salary" => "$1,000,000"}]
    #         is equivalent to 
    #           <merge_field merge_field_name="Salary">
    #           <value>$1,000,000</value>
    #           </merge_field>
    #   * <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   * <b>tags</b>: document tags, an array of {:name => 'tag_name'} (for simple tag) or {:name => 'tag_name', :value => 'value'} (for tuples pairs)
    #       Ex. [{:name => 'sent_from_api'}, {:name => "user_id", :value => "32"}]
    #   * <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
    #       Ex. "http://yoursite/callback"
    # 
    # Ex. call with all options used
    #   @rs_connection.send_template(
    #     "a_1_zcfdidf8fi23", 
    #     "Your Employee Handbook", 
    #     [{"employee" => {:name => "John Employee", :email => "john@employee.com"}}],
    #     {
    #       :description => "Please read over the handbook and sign it.",
    #       :merge_fields => [
    #         { "Department" => "Fun and games" },
    #         { "Salary" => "$1,000,000" }
    #       ],
    #       :expires_in => 5,
    #       :tags => [
    #         {:name => 'sent_from_api'},
    #         {:name => 'user_id', :value => '32'}
    #       ],
    #       :callback_location => "http://yoursite/callback"
    #     })
    def send_template(guid, subject, roles, options={})
      prefill(guid, subject, roles, options.merge({:action => 'send'}))
    end
    
    # Creates a URL that give person ability to create a template in your account.
    # * <b>options</b>: optional options for redirected person
    #   * <b>callback_location</b>: URI encoded URL that specifies the location we will POST a callback notification to when the template has been created.
    #   * <b>redirect_location</b>: A URI encoded URL that specifies the location we will redirect the user to, after they have created a template.
    #   * <b>tags</b>: tags to add to the template. an array of 'tag_name' (for simple tag) or {'tag_name' => 'value'} (for tuples pairs)
    #       Ex. ['created_from_api', {"user_id" => "123"}]
    #   * <b>acceptable_role_names</b>: The user creating the Template will be forced to select one of the values provided. 
    #       There will be no free-form name entry when adding roles to the Template. An array of strings. 
    #       Ex. ["Employee", "Employeer"]
    #   * <b>acceptable_merge_field_names</b>: The user creating the Template will be forced to select one of the values provided. 
    #       There will be no free-form name entry when adding merge fields to the Template.
    #       Ex. ["Location", "Tax ID", "Company Name"]
    def generate_build_url(options={})
      xml_hash = {:template => {}}
      xml_hash[:template][:tags] = TagsHelper.array_to_xml_hash(options[:tags]) if options[:tags]
      
      [:acceptable_merge_field_names, :acceptable_role_names].each do |option|
        xml_hash[:template][option] = array_to_acceptable_names_hash(options[option]) if options[option]
      end
      
      [:callback_location, :redirect_location].each do |other_option|
        xml_hash[:template][other_option] = options[other_option] if options[other_option]
      end

      response = post "/api/templates/generate_build_token.xml", xml_hash
      
      redirect_token = response["token"]["redirect_token"]
      
      "#{site}/builder/new?rt=#{redirect_token}"
    end
    
    # Sends template with all roles as embedded signers and returns an array of hashes with :name and :url for each signer link.
    # * <b>guid</b>: templates guid. Ex. a_1_zcfdidf8fi23
    # * <b>roles</b>: Recipients of the document, should be an array of role names in a hash with keys as role_names. 
    #     Ex. [{"Employee" => {:name => "John Employee"}]
    #       is equivalent to 
    #         <role role_name="Employee">
    #           <name>John Employee</name>
    #           <email>noemail@rightsignature.com</email>
    #         </role>
    # * <b>options</b>: other optional values
    #   * <b>subject</b>: subject of the document that'll appear in email. Defaults to Template's subject
    #   * <b>description</b>: document description that'll appear in the email
    #   * <b>merge_fields</b>: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
    #       Ex. [{"Salary" => "$1,000,000"}]
    #         is equivalent to 
    #           <merge_field merge_field_name="Salary">
    #           <value>$1,000,000</value>
    #           </merge_field>
    #   * <b>expires_in</b>: number of days before expiring the document. API only allows 2,5,15, or 30.
    #   * <b>tags</b>: document tags, an array of {:name => 'tag_name'} (for simple tag) or {:name => 'tag_name', :value => 'value'} (for tuples pairs)
    #       Ex. [{:name => 'sent_from_api'}, {:name => "user_id", :value => "32"}]
    #   * <b>callback_location</b>: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
    #       Ex. "http://yoursite/callback"
    #   * <b>redirect_location</b>: A URI encoded URL that specifies the location for the signing widget to redirect the user to after it is signed. 
    #       Ex. "http://yoursite/thanks_for_signing"
    # 
    # Ex. call with all options used
    #   @rs_connection.send_as_embedded_signers(
    #     "a_1_zcfdidf8fi23", 
    #     "Your Employee Handbook", 
    #     [{"employee" => {:name => "John Employee", :email => "john@employee.com"}}],
    #     {
    #       :description => "Please read over the handbook and sign it.",
    #       :merge_fields => [
    #         { "Department" => "Fun and games" },
    #         { "Salary" => "$1,000,000" }
    #       ],
    #       :expires_in => 5,
    #       :tags => [
    #         {:name => 'sent_from_api'},
    #         {:name => 'user_id', :value => '32'}
    #       ],
    #       :redirect_location => "http://yoursite/redirect_from_signing"
    #     })
    def send_as_embedded_signers(guid, recipients, options={})
      redirect_location = options.delete(:redirect_location)

      response = prepackage(guid)
      template = response["template"]

      recipients.each do |role_hash|
        key, value = role_hash.first
        role_hash[key][:email] = "noemail@rightsignature.com" unless role_hash[key]["email"] || role_hash[key][:email]
      end
      
      response = send_template(template["guid"], options[:subject] || template["subject"], recipients, options)
      document_guid = response["document"]["guid"]
      
      get_document_signer_links_for(document_guid, redirect_location)
    end
    
    
  end
end