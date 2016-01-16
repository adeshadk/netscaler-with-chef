actions  :add,:remove, :set
attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :action_type,:kind_of => Symbol,:default => nil,:equal_to => [:cs, :rewrite, :responder]
attribute :action_operation,:kind_of => String,:default => nil
attribute :action_target,:kind_of => String,:default => nil
attribute :action_htmlpage,:kind_of => String,:default => nil
attribute :action_value,:kind_of => String,:default => nil
attribute :action_targetvserver,:kind_of => String,:default => nil
attribute :action_targetvserverexpr,:kind_of => String,:default => nil
attribute :add_options,:kind_of => String,:default => " -bypassSafetyCheck YES"
attribute :comment,:kind_of => String,:default => ""
