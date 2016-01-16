actions :enable, :disable, :add,:remove,:set,:bind
attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :csvserver_protocol,:kind_of => Symbol,:default => :HTTP,:equal_to => [:HTTP,:SSL,:TCP,:FTP,:RTSP,:SSL_TCP,:UDP,:DNS,:DNS_TCP,:SIP_UDP,:ANY,:RADIUS,:RDP,:MYSQL,:MSSQL,:DIAMETER,:SSL_DIAMETER]
attribute :csvserver_ip,:kind_of => String,:default => nil
attribute :csvserver_port,:kind_of => Fixnum,:default => 80
attribute :default_lbvserver,:kind_of => String,:default => nil
attribute :policy_type,:kind_of => Symbol,:default => nil,:equal_to => [:cs, :rewrite, :responder]
attribute :policy_name,:kind_of => String,:default => nil
attribute :policy_priority,:kind_of => Integer,:default => 100
attribute :policy_flowtype,:kind_of => Symbol,:default => :REQUEST,:equal_to => [:REQUEST, :RESPONSE]
attribute :policy_goto_expression,:kind_of => Symbol,:default => :NEXT,:equal_to => [:NEXT, :END]
attribute :certkey_name,:kind_of => String,:default => nil
attribute :set_options,:kind_of => String,:default => nil
