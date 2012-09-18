require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::Template do 
  describe "list" do
    it "should GET /api/templates.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/templates.xml', {})
      RightSignature::Template.list
    end

    it "should pass search options to /api/templates.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/templates.xml', {:search => "search", :page => 2})
      RightSignature::Template.list(:search => "search", :page => 2)
    end
  end
  
  describe "details" do
    it "should GET /api/templates/MYGUID.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/templates/MYGUID.xml', {})
      RightSignature::Template.details('MYGUID')
    end
  end

  describe "prepackage" do
    it "should POST /api/templates/MYGUID/prepackage.xml" do
      RightSignature::Connection.should_receive(:post).with('/api/templates/MYGUID/prepackage.xml', {})
      RightSignature::Template.prepackage('MYGUID')
    end
  end

  describe "prefill/send_template" do
    it "should POST /api/templates.xml with action of 'prefill', MYGUID guid, roles, and \"sign me\" subject in template hash" do
      RightSignature::Connection.should_receive(:post).with('/api/templates.xml', {:template => {:guid => "MYGUID", :action => "prefill", :subject => "sign me", :roles => []}})
      RightSignature::Template.prefill("MYGUID", "sign me", [])
    end
    
    it "should add \"role role_name='Employee'\" key roles in xml hash" do
      RightSignature::Connection.should_receive(:post).with('/api/templates.xml', {
        :template => {
          :guid => "MYGUID", 
          :action => "prefill",
          :subject => "sign me", 
          :roles => [
            {"role role_name=\'Employee\'" => {
              :name => "John Employee", 
              :email => "john@employee.com", 
            }}
          ]
        }
      })
      RightSignature::Template.prefill("MYGUID", "sign me", [{"Employee" => {:name => "John Employee", :email => "john@employee.com"}}])
    end

    it "should POST /api/templates.xml with action of 'send', MYGUID guid, roles, and \"sign me\" subject in template hash" do
      RightSignature::Connection.should_receive(:post).with('/api/templates.xml', {:template => {:guid => "MYGUID", :action => "send", :subject => "sign me", :roles => []}})
      RightSignature::Template.send_template("MYGUID", "sign me", [])
    end
  end
  
end