module RightSignature
  class Template
    extend RightSignature::Helpers

    class << self
      
      # List Templates and passes in optional options.
      #  Options:
      #   * page: page number
      #   * per_page: number of templates to return per page. 
      #       API only supports 10, 20, 30, 40, or 50. Default is 10.
      #   * tags: filter templates by given tags. Array of strings, for name/value tags colon (:) should separate name and value.
      #       Ex. "single_tag,tag_key:tag_value" would find templates with 'single_tag' and the name/value of 'tag_key' with value 'tag_value'.
      #   * search: term to search for in templates.
      def list(options={})
        options[:tags] = TagsHelper.mixed_array_to_string_array(options[:tags]) if options[:tags]
        RightSignature::Connection.get "/api/templates.xml", options
      end
      
      def details(guid)
        RightSignature::Connection.get "/api/templates/#{guid}.xml", {}
      end
      
      # Clones a template so it can be used for sending. Always first step in sending a template.
      def prepackage(guid)
        RightSignature::Connection.post "/api/templates/#{guid}/prepackage.xml", {}
      end
      
      # Prefills template.
      # * guid: templates guid. Ex. a_1_zcfdidf8fi23
      # * subject: subject of the document that'll appear in email
      # * roles: Recipients of the document, should be an array of role names and emails in a hash with keys as role_names. 
      #     Ex. [{"Employee" => {:name => "John Employee", :email => "john@employee.com"}}]
      #       is equivalent to 
      #         <role role_name="Employee">
      #           <name>John Employee</name>
      #           <email>john@employee.com</email>
      #         </role>
      # * options: other optional values
      #     - description: document description that'll appear in the email
      #     - merge_fields: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
      #         Ex. [{"Salary" => "$1,000,000"}]
      #           is equivalent to 
      #             <merge_field merge_field_name="Salary">
      #             <value>$1,000,000</value>
      #             </merge_field>
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
      #         Ex. ['sent_from_api', {"user_id" => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      # 
      # Ex. call with all options used
      #   RightSignature::Template.prefill(
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
      #       :callback_url => "http://yoursite/callback"
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
        [:expires_in, :description, :callback_url, :action].each do |other_option|
          xml_hash[:template][other_option] = options[other_option] if options[other_option]
        end

        RightSignature::Connection.post "/api/templates.xml", xml_hash
      end
      
      def prepackage_and_send(guid, roles, options={})
        response = prepackage(guid)
        new_guid = response["template"]["guid"]
        send_template(new_guid, options.delete(:subject) || response["template"]["subject"], roles, options)
      end
      
      # Sends template.
      # * guid: templates guid. Ex. a_1_zcfdidf8fi23
      # * subject: subject of the document that'll appear in email
      # * roles: Recipients of the document, should be an array of role names and emails in a hash with keys as role_names. 
      #     Ex. [{"Employee" => {:name => "John Employee", :email => "john@employee.com"}}]
      #       is equivalent to 
      #         <role role_name="Employee">
      #           <name>John Employee</name>
      #           <email>john@employee.com</email>
      #         </role>
      # * options: other optional values
      #     - description: document description that'll appear in the email
      #     - merge_fields: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
      #         Ex. [{"Salary" => "$1,000,000"}]
      #           is equivalent to 
      #             <merge_field merge_field_name="Salary">
      #             <value>$1,000,000</value>
      #             </merge_field>
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of {:name => 'tag_name'} (for simple tag) or {:name => 'tag_name', :value => 'value'} (for tuples pairs)
      #         Ex. [{:name => 'sent_from_api'}, {:name => "user_id", :value => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      # 
      # Ex. call with all options used
      #   RightSignature::Template.prefill(
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
      #       :callback_url => "http://yoursite/callback"
      #     })
      def send_template(guid, subject, roles, options={})
        prefill(guid, subject, roles, options.merge({:action => 'send'}))
      end
      
      # Creates a URL that give person ability to create a template in your account.
      # * options: optional options for redirected person
      #     - callback_location: URI encoded URL that specifies the location we will POST a callback notification to when the template has been created.
      #     - redirect_location: A URI encoded URL that specifies the location we will redirect the user to, after they have created a template.
      #     - tags: tags to add to the template. an array of 'tag_name' (for simple tag) or {'tag_name' => 'value'} (for tuples pairs)
      #         Ex. ['created_from_api', {"user_id" => "123"}]
      #     - acceptabled_role_names: The user creating the Template will be forced to select one of the values provided. 
      #         There will be no free-form name entry when adding roles to the Template. An array of strings. 
      #         Ex. ["Employee", "Employeer"]
      #     - acceptable_merge_field_names: The user creating the Template will be forced to select one of the values provided. 
      #         There will be no free-form name entry when adding merge fields to the Template.
      #         Ex. ["Location", "Tax ID", "Company Name"]
      def generate_build_url(options={})
        xml_hash = {:template => {}}
        xml_hash[:template][:tags] = TagsHelper.array_to_xml_hash(options[:tags]) if options[:tags]
        
        [:acceptable_merge_field_names, :acceptabled_role_names].each do |option|
          xml_hash[:template][option] = array_to_acceptable_names_hash(options[option]) if options[option]
        end
        
        [:callback_location, :redirect_location].each do |other_option|
          xml_hash[:template][other_option] = options[other_option] if options[other_option]
        end

        response = RightSignature::Connection.post "/api/templates/generate_build_token.xml", xml_hash
        
        redirect_token = response["token"]["redirect_token"]
        
        "#{RightSignature::Connection.site}/builder/new?rt=#{redirect_token}"
      end
      
      # Sends template with all roles as embedded signers and returns an array of hashes with :name and :url for each signer link.
      # * guid: templates guid. Ex. a_1_zcfdidf8fi23
      # * roles: Recipients of the document, should be an array of role names in a hash with keys as role_names. 
      #     Ex. [{"Employee" => {:name => "John Employee"}]
      #       is equivalent to 
      #         <role role_name="Employee">
      #           <name>John Employee</name>
      #           <email>noemail@rightsignature.com</email>
      #         </role>
      # * options: other optional values
      #     - subject: subject of the document that'll appear in email. Defaults to Template's subject
      #     - description: document description that'll appear in the email
      #     - merge_fields: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
      #         Ex. [{"Salary" => "$1,000,000"}]
      #           is equivalent to 
      #             <merge_field merge_field_name="Salary">
      #             <value>$1,000,000</value>
      #             </merge_field>
      #     - expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
      #     - tags: document tags, an array of {:name => 'tag_name'} (for simple tag) or {:name => 'tag_name', :value => 'value'} (for tuples pairs)
      #         Ex. [{:name => 'sent_from_api'}, {:name => "user_id", :value => "32"}]
      #     - callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
      #         Ex. "http://yoursite/callback"
      #     - redirect_location: A URI encoded URL that specifies the location for the signing widget to redirect the user to after it is signed. 
      #         Ex. "http://yoursite/thanks_for_signing"
      # 
      # Ex. call with all options used
      #   RightSignature::Template.prefill(
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
      #       :callback_url => "http://yoursite/callback"
      #     })
      def send_as_embedded_signers(guid, recipients, options={})
        redirect_location = options.delete(:redirect_location)

        response = prepackage(guid)
        template = response["template"]

        recipients.each do |role_hash|
          key, value = role_hash.first
          if role_hash[key]["email"]
            role_hash[key]["email"] = "noemail@rightsignature.com"
          else
            role_hash[key][:email] = "noemail@rightsignature.com"
          end
        end
        
        response = send_template(template["guid"], options[:subject] || template["subject"], recipients, options)
        document_guid = response["document"]["guid"]
        
        RightSignature::Document.get_signer_links_for(document_guid, redirect_location)
      end
      
      
    end
  end
end