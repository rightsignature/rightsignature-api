RightSignature API
==================
This gem is a wrapper to RightSignature's API for both OAuth authentication and Token authentication

Setup
-----
After getting an API key from RightSignature, you can use the Secure Token or generate an Access Token with the OAuth key and secret using RightSignature::load_configuration.

#####Using Token authentication
```
RightSignature::load_configuration(:api_token => YOUR_TOKEN)
```

#####Using OAuth authentication
```
RightSignature::load_configuration(:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123")
```
Note: if the both OAuth credentials and api_token are set, the default action is to use Token Authentication.


After loading the configuration, you can use wrappers in RightSignature::Document or RightSignature::Template to call the API. Or use RightSignature::Connection for a more custom call.

Documents
---------
API calls involving documents are wrapped in the RightSignature::Document class.

#####Listing Document
For showing all documents
```
RightSignature::Document.list
```

For showing page 1 of completed and trashed documents, with 20 per page, matching search term 'me', with tag "single_tag" and tag "key" with value of "with_value"
```
options = {
  :state => ['completed', 'trashed'],
  :page => 1,
  :per_page => 20,
  :search => "me",
  :tags => ["single_tag", "key" => "with_value"]
}
RightSignature::Document.list(options)
```
Optional Options:
 * page: page number
 * per_page: number of documents to return per page. 
     API only supports 10, 20, 30, 40, or 50. Default is 10.
 * tags: filter documents with given tags. Tags are an array of strings (single tag) and hashes (tag_name => tag_value).
     Ex. ["single_tag",{"tag_key" => "tag_value"}] would filter documents with 'single_tag' and the name/value of 'tag_key' with value 'tag_value'.
 * search: filter documents with given term.
 * state: An array of document states to filter documents by. 
     API supports 'pending', 'completed', 'trash', and 'pending'.
 * sort: sort documents by given attribute. 
     API supports 'created', 'completed', and 'activity'
 * range: return documents with a certain date range.
     API only supports 'today', 'thisweek', 'thismonth', 'alltime', or a Date
 * recipient_email: filter document where it has a recipient with given email and involves the current OAuth user. 
 * account: include all documents in current account if true. Should be true or false
    Only available for account admins and owners.

#####Document Details
```
RightSignature::Document.details(guid)
```

#####Document Details for Multiple documents
```
RightSignature::Document.batch_details(guids)
```
 * guids: Array of document GUIDs

#####Send Reminder
```
RightSignature::Document.resend_reminder(guid)
```

#####Trash Document
```
RightSignature::Document.trash(guid)
```

#####Extend Expiration of Document by 7 days
```
RightSignature::Document.extend_expiration(guid)
```

#####Replace Tags on Document
```
tags=['sent_from_api', {'user_id' => '12345'}]
RightSignature::Document.update_tags(guid, tags)
```
 * guid
 * tags: An array of 'tag_name' or {'tag_name' => 'tag_value'}

#####Sending New Documents
From file:
```
recipients = [
  {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
  {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
  {'is_sender' => true, :role => 'signer'}
]
options={
  :tags => [{:tag => {:name => 'sent_from_api'}}, {:tag => {:name => 'user_id', :value => '12345'}}],
  :expires_in => '5 days',
  :action => "redirect",
  'callback_location' => "http://example.com/doc_callback",
  'use_text_tags' => false
}

RightSignature::Document.send_document_from_file("here/is/myfile.pdf", 'My Subject', recipients, options)
```
Or
```
RightSignature::Document.send_document_from_file(File.open("here/is/myfile.pdf", 'r'), 'My Subject', recipients)
```
* subject: Document subject
* recipients: Recipients of the document, should be an array of hashes with :name, :email, and :role ('cc' or 'signer'). 
    An optional :is_sender => true can be used to reference the API User and won't need to supply :name and :email. Ex. {:is_sender => true, :role => "cc"}
* Optional options:
    * description: document description that'll appear in the email
    * action: 'send' or 'redirect'. Redirect will prefill the document and generate a redirect token that can be used on for someone to send document under API user's account.
    * expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
    * tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
        Ex. ['sent_from_api', {"user_id" => "32"}]
    * callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
        Ex. "http://yoursite/callback"
    * use_text_tags: Parse document for special Text Tags. true or false.
        More info: https://rightsignature.com/apidocs/text_tags

From raw data:
```
recipients = [
  {:name => "RightSignature", :email => "support@rightsignature.com", :role => 'cc'},
  {:name => "John Bellingham", :email => "john@rightsignature.com", :role => 'signer'},
  {'is_sender' => true, :role => 'signer'}
]
raw_data = File.read("here/is/myfile.pdf")
filename = "Desired Filename.pdf"
RightSignature::Document.send_document_from_file(raw_data, filename, 'My Subject', recipients)
```


Templates
---------
API calls involving documents are wrapped in the RightSignature::Template class.

#####Listing Templates
```
RightSignature::Template.list(options={})
```
Optional Options:
 * page: page number
 * per_page: number of documents to return per page. 
     API only supports 10, 20, 30, 40, or 50. Default is 10.
 * tags: filter documents with given tags. Tags are an array of strings, name and value in a name/value tag should be separated by colon (:).
     Ex. ["single_tag","tag_key:tag_value"] would filter documents with 'single_tag' and the name/value of 'tag_key' with value 'tag_value'.
 * search: filter documents with given term.

#####Template Details
```
RightSignature::Template.details(guid)
```

#####Prepackage and Send template
Most common use of API, clones a template and sends it for signature.
```
RightSignature::Template.prepackage_and_send(guid, subject, roles)
```
Optional options:
 * description: document description that'll appear in the email
 * merge_fields: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
     Ex. [{"Salary" => "$1,000,000"}]
 * expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
 * tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
     Ex. ['sent_from_api', {"user_id" => "32"}]
 * callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
     Ex. "http://yoursite/callback"

#####Template Prepacking
For cloning a Template before sending it.
```
RightSignature::Template.prepackage(guid)
```

#####Template Prefilling
After prepacking, the new template can be updated with prefill data. This won't send out the template as a document.
```
RightSignature::Template.prefill(guid, subject, roles)
```

Optional options:
 * description: document description that'll appear in the email
 * merge_fields: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
     Ex. [{"Salary" => "$1,000,000"}]
 * expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
 * tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
     Ex. ['sent_from_api', {"user_id" => "32"}]
 * callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
     Ex. "http://yoursite/callback"
```
options = {
  :description => "Please read over the handbook and sign it.",
  :merge_fields => [
    { "Department" => "Fun and games" },
    { "Salary" => "$1,000,000" }
  ],
  :expires_in => 5,
  :tags => [
    {:name => 'sent_from_api'},
    {:name => 'user_id', :value => '32'}
  ],
  :callback_url => "http://yoursite/callback"
}
RightSignature::Template.prefill(guid, subject, roles, options)
```


#####Template Sending
Send template as a document for signing. Same options as prefill.
```
RightSignature::Template.send_template(guid, subject, roles)
```

Optional options:
 * description: document description that'll appear in the email
 * merge_fields: document merge fields, should be an array of merge_field_values in a hash with the merge_field_name.
     Ex. [{"Salary" => "$1,000,000"}]
 * expires_in: number of days before expiring the document. API only allows 2,5,15, or 30.
 * tags: document tags, an array of string or hashes 'single_tag' (for simple tag) or {'tag_name' => 'tag_value'} (for tuples pairs)
     Ex. ['sent_from_api', {"user_id" => "32"}]
 * callback_url: A URI encoded URL that specifies the location for API to POST a callback notification to when the document has been created and signed. 
     Ex. "http://yoursite/callback"
```
options = {
  :description => "Please read over the handbook and sign it.",
  :merge_fields => [
    { "Department" => "Fun and games" },
    { "Salary" => "$1,000,000" }
  ],
  :expires_in => 5,
  :tags => [
    {:name => 'sent_from_api'},
    {:name => 'user_id', :value => '32'}
  ],
  :callback_url => "http://yoursite/callback"
}
RightSignature::Template.send_template(guid, subject, roles, options)
```

#####Create New Template Link
Generate a url that let's someone upload and create a template under OAuth user's account.
```
RightSignature::Template.generate_build_url
```

You can also add restrictions to what the person can do:
 * callback_location: URI encoded URL that specifies the location we will POST a callback notification to when the template has been created.
 * redirect_location: A URI encoded URL that specifies the location we will redirect the user to, after they have created a template.
 * tags: tags to add to the template. an array of strings (for simple tag) or hashes like {'tag_name' => 'tag_value'} (for tuples pairs)
     Ex. ['created_from_api', {"user_id" => "123"}]
 * acceptabled_role_names: The user creating the Template will be forced to select one of the values provided. 
     There will be no free-form name entry when adding roles to the Template. An array of strings. 
     Ex. ["Employee", "Employeer"]
 * acceptable_merge_field_names: The user creating the Template will be forced to select one of the values provided. 
     There will be no free-form name entry when adding merge fields to the Template.
     Ex. ["Location", "Tax ID", "Company Name"]
```
options = {
  :acceptable_merge_field_names => 
    [
      {:name => "Site ID"}, 
      {:name => "Starting City"}
    ],
  :acceptabled_role_names => 
    [
      {:name => "Http Monster"}, 
      {:name => "Party Monster"}
    ],
  :callback_location => "http://example.com/done_signing", 
  :redirect_location => "http://example.com/come_back_here"
}
RightSignature::Template.generate_build_url(options)
```


Custom API calls using RightSignature::Connection
-------------------------------------------------

In case there are new API paths, RightSignature::Connection allows a specific path to be specified.
#####Ex. GET https://rightsignature.com/api/documents.xml
```
RightSignature::Connection.get('/api/documents.xml', {:my => 'params'}, {'custom_header' => 'headerValue'})
```

#####Ex. POST https://rightsignature.com/api/documents.xml
```
request_hash= {
  :document => {
    :subject => "Your Form", 
    'document_data' => {:type => 'url', :value => 'http://localhost:3000/sub.pdf' }
  }
}
RightSignature::Connection.post('/api/documents.xml', request_hash, {'custom_header' => 'headerValue'})
```

Development Notes
-----------------
To load in irb from project root:
```
$:.push File.expand_path("../lib", __FILE__); require "rightsignature"; RightSignature::load_configuration(MY_KEYS)
```

TODO:
-----
* Replace Find alternative to gyoku for converting hash to XML with attributes in nodes
* Gemify me
* Have a way for to generate an OAuth Access Token from RightSignature
