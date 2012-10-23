require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::TokenConnection do
  it "should raise error if no configuration is set" do
    token_connection = RightSignature::TokenConnection.new('')
    lambda{token_connection.request(:get, "path", {:query => {:search => 'hey there'}})}.should raise_error(Exception, "Please set api_token")
  end

  it "should create 'api-token' in headers with :api_token credentials, accept of '*/*', and content-type of xml with given method" do
    token_connection = RightSignature::TokenConnection.new('APITOKEN')
    token_connection.class.should_receive(:get).with("path", {:query => {:search => 'hey there'}, :headers => {"api-token" => "APITOKEN", "Accept" => "*/*", "content-type" => "application/xml"}}).and_return(stub("HTTPartyResponse", :parsed_response => nil))
    token_connection.request(:get, "path", {:query => {:search => 'hey there'}})
  end
  
  it "should add 'api-token' to headers with :api_token credentials, accept of '*/*', and content-type of xml with given method" do
    token_connection = RightSignature::TokenConnection.new('APITOKEN')
    token_connection.class.should_receive(:get).with("path", {:query => {:search => 'hey there'}, :headers => {"api-token" => "APITOKEN", "Accept" => "*/*", "content-type" => "application/xml", :my_header => "someHeader"}}).and_return(stub("HTTPartyResponse", :parsed_response => nil))
    token_connection.request(:get, "path", {:query => {:search => 'hey there'}, :headers => {:my_header => "someHeader"}})
  end

  it "should create 'api-token' in headers with :api_token credentials, accept of '*/*', and content-type of xml to POST method" do
    token_connection = RightSignature::TokenConnection.new('APITOKEN')
    token_connection.class.should_receive(:post).with("path", {:body => {:document => {:roles => []}}, :headers => {"api-token" => "APITOKEN", "Accept" => "*/*", "content-type" => "application/xml"}}).and_return(stub("HTTPartyResponse", :parsed_response => nil))
    token_connection.request(:post, "path", {:body => {:document => {:roles => []}}})
  end
  
end
