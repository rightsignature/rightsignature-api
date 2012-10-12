module RightSignature
  module Account 
    # Return account information about API user
    # 
    # Ex. 
    #   @rs_connection.user_details
    # 
    def user_details
      get "/api/users/user_details.xml"
    end
    
    # Creates a user on API user's account
    # * name: User's name
    # * email: User's email
    # 
    # Ex. 
    #   @rs_connection.add_user("John Bellingham", "john@example.com")
    # 
    def add_user(name, email)
      post "/api/users.xml", {:user => {:name => name, :email => email}}
    end
    
    # Return account's usage report (# of documents sent)
    # * <b>since</b>: ("month"/"week"/"day") only count documents sent within a certain time
    # * <b>signed</b>: (true/false) only count signed document
    # 
    # Ex. Return count of signed documents sent this month
    #   @rs_connection.usage_report("month", true)
    # 
    def usage_report(since=nil, signed=nil)
      options = {}
      options[:since] = since if since && ["month", "week", "day"].include?(since)
      options[:signed] = signed.to_s unless signed.nil?
      get "/api/account/usage_report.xml", options
    end
  end
end