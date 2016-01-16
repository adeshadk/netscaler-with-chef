actions :enable, :disable, :add,:set, :bind,:unbind, :remove
attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :lbvserver_protocol,:kind_of => Symbol,:default => :HTTP,:equal_to => [:ANY,:DHCPRA,:DIAMETER,:DNS,:DNS_TCP,:DTLS,:FTP,:HTTP,:MSSQL,:MYSQL,:NNTP,:PUSH,:RADIUS,:RDP,:RTSP,:SIP_UDP,:SSL,:SSL_BRIDGE,:SSL_DIAMETER,:SSL_PUSH,:SSL_TCP,:TCP,:TFTP,:UDP]
attribute :lbvserver_port,:kind_of => Fixnum,:default => 80
attribute :lbvserver_ip,:kind_of => String,:default => nil
attribute :serviceorgroupname,:kind_of => String,:default => nil
attribute :policy_type,:kind_of => Symbol,:default => nil,:equal_to => [:cs, :rewrite, :responder]
attribute :policy_name,:kind_of => String,:default => nil
attribute :policy_priority,:kind_of => Integer,:default => 100
attribute :policy_flowtype,:kind_of => Symbol,:default => :REQUEST,:equal_to => [:REQUEST, :RESPONSE]
attribute :policy_goto_expression,:kind_of => Symbol,:default => :NEXT,:equal_to => [:NEXT, :END]
attribute :certkey_name,:kind_of => String,:default => nil
attribute :add_options,:kind_of => String,:default => ' -persistenceType NONE -lbMethod LEASTCONNECTION '
attribute :set_options,:kind_of => String,:default => nil
