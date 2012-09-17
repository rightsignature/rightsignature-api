RightSignature API
==================
This gem is a wrapper to RightSignature's API for both OAuth authentication and Token authentication

#####Using Token authentication
```
RightSignature::load_configuration(:api_token => YOUR_TOKEN)
```

#####Using OAuth authentication
```
RightSignature::load_configuration(:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123")
```
Note: if the both OAuth credentials and api_token are set, the default action is to use Token Authenication.



Custom API calls using RightSignature::Connection
-------------------------------------------------

In case there are new API paths, RightSignature::Connection allows a specific path to be specified.
Ex. GET https://rightsignature.com/api/documents
RightSignature::Connection.get('/api/documents', {:my => 'params'}, {'custom_header' => 'headerValue'})

Ex. POST https://rightsignature.com/api/documents
request_hash= {
  :document => {
    :subject => "Your Form", 
    'document_data' => {:type => 'url', :value => 'http://localhost:3000/sub.pdf' }
  }
}
RightSignature::Connection.post('/api/documents', request_hash, {'custom_header' => 'headerValue'})


TODO:
-----
Clean up OAuthConnection class
Flush out Template class
Add methods for Document redirect and simpler sending, reduce need of making a hash
Add specs for Document
Gemify me