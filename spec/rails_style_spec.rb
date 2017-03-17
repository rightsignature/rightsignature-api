require File.dirname(__FILE__) + '/spec_helper.rb'

describe "RightSignature::RailsStyle" do
  describe "send_document" do
    it 'can accept strings or symbols for options' do

      @rs.should_receive(:post).with('/api/templates/GUID123/prepackage.xml',
        {}
      ).and_return({"template" => {
        "guid" => "a_123985_1z9v8pd654",
        "subject" => "subject template",
        "message" => "Default message here",
      }})

      @rs.should_receive(:post).with('/api/templates.xml', {:template => {
          :guid => "a_123985_1z9v8pd654",
          :action => "send",
          :subject => "sign me",
          :roles => []
        }})

      @rs.prepackage_and_send("GUID123", [], {"subject" => "sign me"})
    end
  end
end
