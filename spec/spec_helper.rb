require 'rubygems'
require 'rspec'

require File.dirname(__FILE__) + '/../lib/rightsignature'

RSpec.configure do |c|
  c.mock_with :rspec

  c.before(:each) do
    RightSignature::configuration = {:consumer_key => "Consumer123", :consumer_secret => "Secret098", :access_token => "AccessToken098", :access_secret => "AccessSecret123", :api_token => "APITOKEN"}
  end
end
