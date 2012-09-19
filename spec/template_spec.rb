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
    
    it "should convert tags array of mixed strings and hashes into into normalized Tag string" do
      RightSignature::Connection.should_receive(:get).with('/api/templates.xml', {:tags => "hello,abc:def,there"})
      RightSignature::Template.list(:tags => ["hello", {"abc" => "def"}, "there"])
    end

    it "should keep tags as string if :tags is a string" do
      RightSignature::Connection.should_receive(:get).with('/api/templates.xml', {:tags => "voice,no:way,microphone"})
      RightSignature::Template.list(:tags => "voice,no:way,microphone")
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
    
    it "should add \"role role_name='Employee'\" key to roles in xml hash" do
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

    describe "optional options" do
      it "should add \"merge_field merge_field_name='Tax_id'\" key to merge_fields in xml hash" do
        RightSignature::Connection.should_receive(:post).with('/api/templates.xml', {
          :template => {
            :guid => "MYGUID", 
            :action => "prefill",
            :subject => "sign me", 
            :roles => [
            ],
            :merge_fields => [{"merge_field merge_field_name=\'Tax_id\'" => {:value => "123456"}}]
          }
        })
        RightSignature::Template.prefill("MYGUID", "sign me", [], {:merge_fields => [{"Tax_id" => "123456"}]})
      end

      it "should add \"tag\" key to tags in xml hash" do
        RightSignature::Connection.should_receive(:post).with('/api/templates.xml', {
          :template => {
            :guid => "MYGUID", 
            :action => "prefill",
            :subject => "sign me", 
            :roles => [],
            :tags => [{:tag => {:name => "I_Key", :value => "I_Value"}}, {:tag => {:name => "Alone"}}]
          }
        })
        RightSignature::Template.prefill("MYGUID", "sign me", [], {:tags => [{"I_Key" => "I_Value"}, "Alone"]})
      end

      it "should include options :expires_in, :description, and :callback_url" do
        RightSignature::Connection.should_receive(:post).with('/api/templates.xml', {
          :template => {
            :guid => "MYGUID", 
            :action => "prefill",
            :subject => "sign me", 
            :roles => [],
            :expires_in => 15, 
            :description => "Hey, I'm a description", 
            :callback_url => 'http://example.com/callie'
          }
        })
        RightSignature::Template.prefill("MYGUID", "sign me", [], {:expires_in => 15, :description => "Hey, I'm a description", :callback_url => "http://example.com/callie"})
      end
    end

    it "should POST /api/templates.xml with action of 'send', MYGUID guid, roles, and \"sign me\" subject in template hash" do
      RightSignature::Connection.should_receive(:post).with('/api/templates.xml', {:template => {:guid => "MYGUID", :action => "send", :subject => "sign me", :roles => []}})
      RightSignature::Template.send_template("MYGUID", "sign me", [])
    end
  end
  
  describe "generate_build_url" do
    it "should POST /api/templates/generate_build_token.xml" do
      RightSignature::Connection.should_receive(:post).with("/api/templates/generate_build_token.xml", {:template => {}}).and_return({"token"=>{"redirect_token" => "REDIRECT_TOKEN"}})
      RightSignature::Template.generate_build_url
    end

    it "should return https://rightsignature.com/builder/new?rt=REDIRECT_TOKEN" do
      RightSignature::Connection.should_receive(:post).with("/api/templates/generate_build_token.xml", {:template => {}}).and_return({"token"=>{"redirect_token" => "REDIRECT_TOKEN"}})
      RightSignature::Template.generate_build_url.should == "#{RightSignature::Connection.site}/builder/new?rt=REDIRECT_TOKEN"
    end

    describe "options" do
      it "should include normalized :acceptable_merge_field_names in params" do
        RightSignature::Connection.should_receive(:post).with("/api/templates/generate_build_token.xml", {:template => 
          {:acceptable_merge_field_names => 
            [
              {:name => "Site ID"}, 
              {:name => "Starting City"}
            ]}
        }).and_return({"token"=>{"redirect_token" => "REDIRECT_TOKEN"}})
        RightSignature::Template.generate_build_url(:acceptable_merge_field_names => ["Site ID", "Starting City"])
      end

      it "should include normalized :acceptabled_role_names, in params" do
        RightSignature::Connection.should_receive(:post).with("/api/templates/generate_build_token.xml", {:template => 
          {:acceptabled_role_names => 
            [
              {:name => "Http Monster"}, 
              {:name => "Party Monster"}
            ]}
        }).and_return({"token"=>{"redirect_token" => "REDIRECT_TOKEN"}})
        RightSignature::Template.generate_build_url(:acceptabled_role_names => ["Http Monster", "Party Monster"])
      end

      it "should include :callback_location and :redirect_location in params" do
        RightSignature::Connection.should_receive(:post).with("/api/templates/generate_build_token.xml", {:template => {
          :callback_location => "http://example.com/done_signing", 
          :redirect_location => "http://example.com/come_back_here"
        }}).and_return({"token"=>{"redirect_token" => "REDIRECT_TOKEN"}})

        RightSignature::Template.generate_build_url(:callback_location => "http://example.com/done_signing", :redirect_location => "http://example.com/come_back_here")
      end
    end
  end
end