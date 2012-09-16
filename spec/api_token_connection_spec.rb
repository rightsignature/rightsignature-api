require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::TokenConnection do
  it "should create 'api-token' to headers with :api_token credentials, accept of '*/*', and content-type of xml with given method" do
    RightSignature::TokenConnection.should_receive(:get).with("path", {:query => {:search => 'hey there'}, :headers => {"api-token" => "APITOKEN", "Accept" => "*/*", "content-type" => "application/xml"}}).and_return(stub("HTTPartyResponse", :parsed_response => nil))
    RightSignature::TokenConnection.request(:get, "path", {:query => {:search => 'hey there'}})
  end
  
  it "should add 'api-token' to headers with :api_token credentials, accept of '*/*', and content-type of xml with given method" do
    RightSignature::TokenConnection.should_receive(:get).with("path", {:query => {:search => 'hey there'}, :headers => {"api-token" => "APITOKEN", "Accept" => "*/*", "content-type" => "application/xml", :my_header => "someHeader"}}).and_return(stub("HTTPartyResponse", :parsed_response => nil))
    RightSignature::TokenConnection.request(:get, "path", {:query => {:search => 'hey there'}, :headers => {:my_header => "someHeader"}})
  end

  it "should create 'api-token' to headers with :api_token credentials, accept of '*/*', and content-type of xml to POST method" do
    RightSignature::TokenConnection.should_receive(:post).with("path", {:body => {:document => {:roles => []}}, :headers => {"api-token" => "APITOKEN", "Accept" => "*/*", "content-type" => "application/xml"}}).and_return(stub("HTTPartyResponse", :parsed_response => nil))
    RightSignature::TokenConnection.request(:post, "path", {:body => {:document => {:roles => []}}})
  end
  
end