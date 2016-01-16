actions :enable, :disable, :add,:remove
attribute :name,:name_attribute => true
attribute :ns_ip ,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :server_ip,:kind_of => String, :default => nil
attribute :disable_timeout,:kind_of => Fixnum,:default => 6000
attribute :disable_graceful,:kind_of => String,:default => true
