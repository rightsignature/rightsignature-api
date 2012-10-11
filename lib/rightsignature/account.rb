module RightSignature
  module Account 
    def user_details
      get "/api/users/user_details.xml"
    end
    
    def add_user(name, email)
      post "/api/users.xml", {:user => {:name => name, :email => email}}
    end
    
    def usage_report(since=nil, signed=nil)
      options = {}
      options[:since] = since if since && ["month", "week", "day"].include?(since)
      options[:signed] = signed.to_s unless signed.nil?
      get "/api/account/usage_report.xml", options
    end
  end
end