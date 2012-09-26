require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::Account do
  describe "user_details" do
    it "should GET /api/users/user_details.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/users/user_details.xml')
      RightSignature::Account.user_details
    end
  end

  describe "add_user" do
    it "should POST /api/users.xml with user email and name in hash" do
      RightSignature::Connection.should_receive(:post).with('/api/users.xml', {:user => {:name => "Jimmy Cricket", :email => "jimmy@example.com"}})
      RightSignature::Account.add_user("Jimmy Cricket", "jimmy@example.com")
    end
  end
  
  describe "usage_report" do
    it "should GET /api/account/usage_report.xml" do
      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {})
      RightSignature::Account.usage_report
    end

    it "should GET /api/account/usage_report.xml with acceptable param for :since" do
      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {:since => "week"})
      RightSignature::Account.usage_report("week")

      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {:since => "month"})
      RightSignature::Account.usage_report("month")

      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {:since => "day"})
      RightSignature::Account.usage_report("day")

      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {})
      RightSignature::Account.usage_report("1/4/90")
    end
    
    it "should GET /api/account/usage_report.xml with param :signed" do
      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "true"})
      RightSignature::Account.usage_report(nil, true)

      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "false"})
      RightSignature::Account.usage_report(nil, false)
    end

    it "should GET /api/account/usage_report.xml with params :since and :signed" do
      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "true"})
      RightSignature::Account.usage_report(nil, true)

      RightSignature::Connection.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "false"})
      RightSignature::Account.usage_report(nil, false)
    end
  end
end