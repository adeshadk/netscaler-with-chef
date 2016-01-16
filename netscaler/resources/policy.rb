actions  :add,:remove, :set

attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :policy_type,:kind_of => Symbol,:default => nil,:equal_to => [:cs, :rewrite, :responder]
attribute :policy_rule,:kind_of => String,:default => nil,:required => true
attribute :policy_action,:kind_of => String,:default => nil,:required => true
attribute :logAction,:kind_of => String,:default => nil
attribute :comment,:kind_of => String,:default => ""
