actions :enable, :disable, :add, :set, :remove, :bindmonitor,:unbindmonitor

attribute :name,:name_attribute => true
attribute :ns_ip,:default => node['netscaler']['management_ip']
attribute :ns_user,:default => node['netscaler']['login_name']
attribute :ns_passwd,:default => node['netscaler']['login_passwd']
attribute :service_member_name,:kind_of => String,:default => nil
attribute :protocol_type,:kind_of => Symbol,:default => :HTTP,:equal_to => [:ANY,:DHCPRA,:DIAMETER,:DNS,:DNS_TCP,:DTLS,:FTP,:HTTP,:MSSQL,:MYSQL,:NNTP,:PUSH,:RADIUS,:RDP,:RTSP,:SIP_UDP,:SSL,:SSL_BRIDGE,:SSL_DIAMETER,:SSL_PUSH,:SSL_TCP,:TCP,:TFTP,:UDP]
attribute :service_member_port,:kind_of => Fixnum,:default => 80
attribute :monitor_name,:kind_of => String,:default =>'http-ecv'
attribute :disable_timeout,:kind_of => Fixnum,:default => 0
attribute :disable_graceful,:kind_of => String,:default => 'true',:equal_to =>['true','false']
attribute :add_options, :kind_of => String,:default => '-cip ENABLED CLIENT-IP  -sp ON -downStateFlush ENABLED'
attribute :set_options, :kind_of => String,:default => '-cip ENABLED CLIENT-IP  -sp ON -downStateFlush ENABLED'
