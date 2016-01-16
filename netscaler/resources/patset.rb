actions  :add,:remove,:bind,:unbind
attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :pattern,:kind_of => String,:default => nil
attribute :index,:kind_of => Integer,:default => nil
attribute :comments,:kind_of => String,:default => ""
