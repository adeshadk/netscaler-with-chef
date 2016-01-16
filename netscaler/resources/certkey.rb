actions  :add,:remove
attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :certpath,:kind_of => String,:default => nil
attribute :keypath,:kind_of => String,:default => nil
attribute :password,:kind_of => String,:default => nil
attribute :certformat,:kind_of => Symbol,:equal_to => [:PEM, :DER, :PFX],:default => :PEM
attribute :add_options,:kind_of => String,:default => " -expiryMonitor ENABLED -notificationPeriod 90"
attribute :comments,:kind_of => String,:default => ""
