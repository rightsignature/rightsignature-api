require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::Document do
  describe "list" do
    it "should GET /documents.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/documents.xml', {})
      RightSignature::Document.list
    end
    
    it "should pass search options to /api/templates.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/documents.xml', {:search => "search", :page => 2})
      RightSignature::Document.list(:search => "search", :page => 2)
    end

    it "should convert array in options :tags into a string" do
      RightSignature::Connection.should_receive(:get).with('/api/documents.xml', {:tags => "hello,what_is:up"})
      RightSignature::Document.list(:tags => ['hello', {'what_is' => "up"}])
    end

    it "should convert array of options :state into a string" do
      RightSignature::Connection.should_receive(:get).with('/api/documents.xml', {:state => 'pending,trashed'})
      RightSignature::Document.list(:state => ['pending', 'trashed'])
    end
  end
  
  describe "details" do
    it "should GET /api/documentsMYGUID.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/documents/MYGUID.xml')
      RightSignature::Document.details('MYGUID')
    end
  end
  
  describe "details" do
    it "should GET /api/documentsMYGUID.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/documents/MYGUID.xml')
      RightSignature::Document.details('MYGUID')
    end
  end

  describe "batch_details" do
    it "should GET /api/documentsMYGUID1,MYGUID2.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/documents/MYGUID1,MYGUID2/batch_details.xml')
      RightSignature::Document.batch_details(['MYGUID1','MYGUID2'])
    end
  end

  describe "send_reminder" do
    it "should POST /api/documentsMYGUID/send_reminders.xml" do
      RightSignature::Connection.should_receive(:post).with('/api/documents/MYGUID/send_reminders.xml', {})
      RightSignature::Document.send_reminder('MYGUID')
    end
  end
  
  describe "trash" do
    it "should POST /api/documents/MYGUID/trash.xml" do
      RightSignature::Connection.should_receive(:post).with('/api/documents/MYGUID/trash.xml', {})
      RightSignature::Document.trash('MYGUID')
    end
  end
  
  describe "extend_expiration" do
    it "should POST /api/documents/MYGUID/extend_expiration.xml" do
      RightSignature::Connection.should_receive(:post).with('/api/documents/MYGUID/extend_expiration.xml', {})
      RightSignature::Document.extend_expiration('MYGUID')
    end
  end
  
  describe "update_tags" do
    it "should POST /api/documents/MYGUID/update_tags.xml" do
      RightSignature::Connection.should_receive(:post).with('/api/documents/MYGUID/update_tags.xml', {:tags => []})
      RightSignature::Document.update_tags('MYGUID', [])
    end

    it "should normalize tags array into expected hash format" do
      RightSignature::Connection.should_receive(:post).with('/api/documents/MYGUID/update_tags.xml', {
        :tags => [{:tag => {:name => 'myNewOne'}}, {:tag => {:name => 'should_replace', :value => 'the_old_new'}}]
      })
      RightSignature::Document.update_tags('MYGUID', ["myNewOne", {"should_replace" => "the_old_new"}])
    end

    it "should allow empty tags array" do
      RightSignature::Connection.should_receive(:post).with('/api/documents/MYGUID/update_tags.xml', {
        :tags => []
      })
      RightSignature::Document.update_tags('MYGUID', [])
    end
  end

  describe "send_document" do
    it "should POST /api/documents.xml"
  end
end