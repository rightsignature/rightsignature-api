require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::Document do
  describe "documents_list" do
    it "should GET /documents.xml" do
      @rs.should_receive(:get).with('/api/documents.xml', {})
      @rs.documents_list
    end

    it "should pass search options to /api/templates.xml" do
      @rs.should_receive(:get).with('/api/documents.xml', {:search => "search", :page => 2})
      @rs.documents_list(:search => "search", :page => 2)
    end

    it "should convert array in options :tags into a string" do
      @rs.should_receive(:get).with('/api/documents.xml', {:tags => "hello,what_is:up"})
      @rs.documents_list(:tags => ['hello', {'what_is' => "up"}])
    end

    it "should convert array of options :state into a string" do
      @rs.should_receive(:get).with('/api/documents.xml', {:state => 'pending,trashed'})
      @rs.documents_list(:state => ['pending', 'trashed'])
    end
  end

  describe "details" do
    it "should GET /api/documentsMYGUID.xml" do
      @rs.should_receive(:get).with('/api/documents/MYGUID.xml')
      @rs.document_details('MYGUID')
    end
  end

  describe "details" do
    it "should GET /api/documentsMYGUID.xml" do
      @rs.should_receive(:get).with('/api/documents/MYGUID.xml')
      @rs.document_details('MYGUID')
    end
  end

  describe "documents_batch_details" do
    it "should GET /api/documentsMYGUID1,MYGUID2.xml" do
      @rs.should_receive(:get).with('/api/documents/MYGUID1,MYGUID2/batch_details.xml')
      @rs.documents_batch_details(['MYGUID1','MYGUID2'])
    end
  end

  describe "send_reminder" do
    it "should POST /api/documentsMYGUID/send_reminders.xml" do
      @rs.should_receive(:post).with('/api/documents/MYGUID/send_reminders.xml', {})
      @rs.send_reminder('MYGUID')
    end
  end

  describe "trash" do
    it "should POST /api/documents/MYGUID/trash.xml" do
      @rs.should_receive(:post).with('/api/documents/MYGUID/trash.xml', {})
      @rs.trash_document('MYGUID')
    end
  end

  describe "extend_document_expiration" do
    it "should POST /api/documents/MYGUID/extend_expiration.xml" do
      @rs.should_receive(:post).with('/api/documents/MYGUID/extend_expiration.xml', {})
      @rs.extend_document_expiration('MYGUID')
    end
  end

  describe "update_document_tags" do
    it "should POST /api/documents/MYGUID/update_tags.xml" do
      @rs.should_receive(:post).with('/api/documents/MYGUID/update_tags.xml', {:tags => []})
      @rs.update_document_tags('MYGUID', [])
    end

    it "should normalize tags array into expected hash format" do
      @rs.should_receive(:post).with('/api/documents/MYGUID/update_tags.xml', {
        :tags => [{:tag => {:name => 'myNewOne'}}, {:tag => {:name => 'should_replace', :value => 'the_old_new'}}]
      })
      @rs.update_document_tags('MYGUID', ["myNewOne", {"should_replace" => "the_old_new"}])
    end

    it "should allow empty tags array" do
      @rs.should_receive(:post).with('/api/documents/MYGUID/update_tags.xml', {
        :tags => []
      })
      @rs.update_document_tags('MYGUID', [])
    end
  end

  describe "send_document" do
    it "should POST /api/documents.xml with document hash containing given subject, document data, recipients, and action of 'send'" do
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :document_data => {:type => 'base64', :filename => "originalfile.pdf", :value => "mOio90cv"},
          :recipients => [],
          :action => "send"
        }
      })
      document_data = {:type => 'base64', :filename => "originalfile.pdf", :value => "mOio90cv"}
      @rs.send_document("subby", [], document_data)
    end

    it "should POST /api/documents.xml should convert recipients into normalized format" do
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :document_data => {:type => 'base64', :filename => "originalfile.pdf", :value => "mOio90cv"},
          :recipients => [
            {:recipient => {:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}},
            {:recipient =>{:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}}
          ],
          :action => "send"
        }
      })
      document_data = {:type => 'base64', :filename => "originalfile.pdf", :value => "mOio90cv"}
      recipients = [{:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}, {:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}]

      @rs.send_document("subby", recipients, document_data)
    end

    it "should POST /api/documents.xml with options" do
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :document_data => {:type => 'base64', :filename => "originalfile.pdf", :value => "mOio90cv"},
          :recipients => [
            {:recipient => {:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}},
            {:recipient =>{:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}}
          ],
          :action => "send",
          :description => "My descript",
          :callback_url => "http://example.com/call"
        }
      })
      document_data = {:type => 'base64', :filename => "originalfile.pdf", :value => "mOio90cv"}
      recipients = [{:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}, {:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}]

      options = {
        :description => "My descript",
        :callback_url => "http://example.com/call"
      }
      @rs.send_document("subby", recipients, document_data, options)
    end
  end

  describe "send_document_from_data" do
    it "should POST /api/documents.xml with document hash containing given subject, Base64 encoded version of document data, recipients, and action of 'send'" do
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :document_data => {:type => 'base64', :filename => "my fresh upload.pdf", :value => Base64::encode64("THIS IS MY data")},
          :recipients => [],
          :action => "send"
        }
      })
      @rs.send_document_from_data("THIS IS MY data", "my fresh upload.pdf", "subby", [])
    end

    it "should POST /api/documents.xml with options" do
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :action => "send",
          :document_data => {:type => 'base64', :filename => "uploaded.pdf", :value => Base64::encode64("THIS")},
          :recipients => [
            {:recipient => {:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}},
            {:recipient =>{:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}}
          ],
          :description => "My descript",
          :callback_url => "http://example.com/call"
        }
      })

      recipients = [{:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}, {:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}]
      options = {
        :description => "My descript",
        :callback_url => "http://example.com/call"
      }
      @rs.send_document_from_data("THIS", "uploaded.pdf", "subby", recipients, options)
    end
  end

  describe "send_document_from_file" do
    it "should open File and base64 encode it" do
      # Probably get a fixture or something here
      file = File.new(File.dirname(__FILE__) + '/spec_helper.rb')
      fake_data = "abc"
      File.should_receive(:read).with(file).and_return(fake_data)
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :action => "send",
          :document_data => {:type => 'base64', :filename => "spec_helper.rb", :value => Base64::encode64(fake_data)},
          :recipients => []
        }
      })

      @rs.send_document_from_file(file, "subby", [])
    end

    it "should open path to file and base64 encode it" do
      file_path = '/tmp/temp.pdf'
      fake_data = "abc"
      File.should_receive(:read).with(file_path).and_return(fake_data)
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :action => "send",
          :document_data => {:type => 'base64', :filename => "temp.pdf", :value => Base64::encode64(fake_data)},
          :recipients => []
        }
      })
      @rs.send_document_from_file(file_path, "subby", [])
    end

    it "should POST /api/documents.xml with options" do
      file_path = '/tmp/temp.pdf'
      fake_data = "abc"
      File.should_receive(:read).with(file_path).and_return(fake_data)
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subby",
          :action => "send",
          :document_data => {:type => 'base64', :filename => "temp.pdf", :value => Base64::encode64(fake_data)},
          :recipients => [
            {:recipient => {:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}},
            {:recipient =>{:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}}
          ],
          :description => "My descript",
          :callback_url => "http://example.com/call"
        }
      })

      recipients = [{:name => "Signy Sign", :email => "signy@example.com", :role => "signer"}, {:name => "Cee Cee", :email => "ccme@example.com", :role => "cc"}]
      options = {
        :description => "My descript",
        :callback_url => "http://example.com/call"
      }
      @rs.send_document_from_file(file_path, "subby", recipients, options)
    end
  end

  describe "generate_document_url" do
    it "should POST /api/documents.xml with redirect action and return https://rightsignature.com/builder/new?rt=REDIRECT_TOKEN" do
      @rs.should_receive(:post).with("/api/documents.xml", {
        :document => {
          :subject => "subjy",
          :action => "redirect",
          :document_data => {},
          :recipients => [],
        }
      }).and_return({"document"=>{"redirect_token" => "REDIRECT_TOKEN"}})
      @rs.generate_document_redirect_url("subjy", [], {}).should == "#{@rs.site}/builder/new?rt=REDIRECT_TOKEN"
    end
  end

  describe "get_document_signer_links_for" do
    it "should GET /api/documents/GUID123/signer_links.xml and return urls for signers" do
      @rs.should_receive(:get).with("/api/documents/GUID123/signer_links.xml", {}).and_return({'document' => {'signer_links' => {'signer_link' => [
        {"signer_token" => "avx37", "name" => "John Bellingham"},
        {"signer_token" => "fdh89", "name" => "Righty Jones"}]
      }}})

      response = @rs.get_document_signer_links_for("GUID123")
      response.size.should == 2
      response.include?({"name" => "John Bellingham", "url" => "#{@rs.site}/signatures/embedded?rt=avx37"}).should be true
      response.include?({"name" => "Righty Jones", "url" => "#{@rs.site}/signatures/embedded?rt=fdh89"}).should be true
    end

    it "should GET /api/documents/GUID123/signer_links.xml with URI encoded redirect location and return urls for signers" do
      @rs.should_receive(:get).with("/api/documents/GUID123/signer_links.xml", {:redirect_location => "http://google.com/redirected%20location"}
      ).and_return({'document' => {'signer_links' => {'signer_link' => [
        {"signer_token" => "avx37", "name" => "John Bellingham"},
        {"signer_token" => "fdh89", "name" => "Righty Jones"}]
      }}})

      response = @rs.get_document_signer_links_for("GUID123", "http://google.com/redirected location")
      response.size.should == 2
      response.include?({"name" => "John Bellingham", "url" => "#{@rs.site}/signatures/embedded?rt=avx37"}).should be true
      response.include?({"name" => "Righty Jones", "url" => "#{@rs.site}/signatures/embedded?rt=fdh89"}).should be true
    end

    it "should GET /api/documents/GUID123/signer_links.xml and return [] for no signers" do
      @rs.should_receive(:get).with("/api/documents/GUID123/signer_links.xml", {}).and_return({'document' => {'signer_links' => nil}})

      response = @rs.get_document_signer_links_for("GUID123")
      response.should == []
    end

    it "should GET /api/documents/GUID123/signer_links.xml with URI encoded redirect location and return urls for 1 signer_link" do
      @rs.should_receive(:get).with("/api/documents/GUID123/signer_links.xml", {:redirect_location => "http://google.com/redirected%20location"}
      ).and_return({'document' => {'signer_links' => {'signer_link' =>
        {"signer_token" => "fdh89", "name" => "Righty Jones"}
      }}})

      response = @rs.get_document_signer_links_for("GUID123", "http://google.com/redirected location")
      response.size.should == 1
      response.include?({"name" => "Righty Jones", "url" => "#{@rs.site}/signatures/embedded?rt=fdh89"}).should be true
    end
  end
end
