require File.dirname(__FILE__) + '/spec_helper.rb'

describe RightSignature::Account do
  describe "user_details" do
    it "should GET /api/users/user_details.xml" do
      @rs.should_receive(:get).with('/api/users/user_details.xml')
      @rs.user_details
    end
  end

  describe "add_user" do
    it "should POST /api/users.xml with user email and name in hash" do
      @rs.should_receive(:post).with('/api/users.xml', {:user => {:name => "Jimmy Cricket", :email => "jimmy@example.com"}})
      @rs.add_user("Jimmy Cricket", "jimmy@example.com")
    end
  end
  
  describe "usage_report" do
    it "should GET /api/account/usage_report.xml" do
      @rs.should_receive(:get).with('/api/account/usage_report.xml', {})
      @rs.usage_report
    end

    it "should GET /api/account/usage_report.xml with acceptable param for :since" do
      @rs.should_receive(:get).with('/api/account/usage_report.xml', {:since => "week"})
      @rs.usage_report("week")

      @rs.should_receive(:get).with('/api/account/usage_report.xml', {:since => "month"})
      @rs.usage_report("month")

      @rs.should_receive(:get).with('/api/account/usage_report.xml', {:since => "day"})
      @rs.usage_report("day")

      @rs.should_receive(:get).with('/api/account/usage_report.xml', {})
      @rs.usage_report("1/4/90")
    end
    
    it "should GET /api/account/usage_report.xml with param :signed" do
      @rs.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "true"})
      @rs.usage_report(nil, true)

      @rs.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "false"})
      @rs.usage_report(nil, false)
    end

    it "should GET /api/account/usage_report.xml with params :since and :signed" do
      @rs.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "true"})
      @rs.usage_report(nil, true)

      @rs.should_receive(:get).with('/api/account/usage_report.xml', {:signed => "false"})
      @rs.usage_report(nil, false)
    end
  end
end