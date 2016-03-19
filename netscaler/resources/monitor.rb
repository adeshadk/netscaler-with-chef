actions  :add,:remove,:set
attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :type,:kind_of => Symbol,:default => :"http-ecv",:equal_to => [:"http-ecv", :"mssql-ecv", :tcp,:"udp-ecv",:http]
attribute :send_string,:kind_of => String,:default => nil
attribute :recv_string,:kind_of => String,:default => nil
attribute :custom_headers,:kind_of => String,:default => ""
attribute :http_request,:kind_of => String,:default => nil
attribute :response_codes,:kind_of => String,:default => ""
attribute :db_user,:kind_of => String,:default => nil #this user need to exists on netscaler beforehand
attribute :db_name,:kind_of => String,:default => nil
attribute :db_query,:kind_of => String,:default => nil
attribute :db_eval_rule,:kind_of => String,:default => nil
attribute :options, :kind_of => String,:default => ''
attribute :add_options, :kind_of => String,:default => ' -LRTM ENABLED'
attribute :set_options, :kind_of => String,:default => ' -LRTM ENABLED'
attribute :comments,:kind_of => String,:default => ""
