
require 'net/ssh'

action :enable do
  # enable lb vserver $NAME
  unless enabled?
    begin
      command = "enable lb vserver #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB vServer #{new_resource.name} enabled")
      else
        Chef::Log.warn("LB vServer #{new_resource.name} not enabled: #{output}")
      end
    ensure
      close
    end
  end
end

action :disable do
  # disable lb vserver $NAME
  if enabled?
    begin
      command = "disable lb vserver #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB vServer #{new_resource.name} disabled")
      else
        Chef::Log.warn("Disabling LB vServer #{new_resource.name} failed")
      end
    ensure
      close
    end   # begin
  else
    Chef::Log.info("LB vServer #{new_resource.name} already disabled")
  end     # if enabled
end       # action


action :add do
  # add lb vserver $NAME HTTP [IP] [Port]
  unless exists?
    begin
      Chef::Log.info("Adding LB vServer #{new_resource.name} on #{new_resource.ns_ip}")
      command = "add lb vserver #{new_resource.name} "
      if new_resource.lbvserver_ip != nil && new_resource.lbvserver_ip !=""
        command << " #{new_resource.lbvserver_protocol}  #{new_resource.lbvserver_ip} #{new_resource.lbvserver_port}"
      else # no ip defined so it is dummy Vserver, needed for Content Switch Vserver
          command << " #{new_resource.lbvserver_protocol} "
      end
      if new_resource.add_options
        command << " #{new_resource.add_options}"
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB vServer #{new_resource.name} added")
      else
        Chef::Log.warn("Adding LB vServer  #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("LB vServer  #{new_resource.name} already exists")
  end
end
action :set do
  # set lb vserver $NAME [options]
  if exists?
    begin
      Chef::Log.info("Setting LB vServer  #{new_resource.name} on #{new_resource.ns_ip}")
      command = "set lb vserver #{new_resource.name} "

      if new_resource.set_options
        command << " -persistenceType NONE -lbMethod LEASTCONNECTION "
      end
		#Setting comments
        command << " -comment 'LB vServer for environment #{new_resource.name}'"

      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB vServer  #{new_resource.name} has been set")
      else
        Chef::Log.warn("Setting LB vServer  #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("LB vServer  #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :bind do
  # bind lb vserver $NAME $SERVERNAME $PORT
  if exists?
    begin
	    if  new_resource.policy_type != nil && "#{new_resource.policy_type.to_s}"=="responder"
        command = "bind lb vserver #{new_resource.name} -policyname #{new_resource.policy_name} -priority #{new_resource.policy_priority}"
        Chef::Log.info("Binding  LB vServer  #{new_resource.name} to policy #{new_resource.policy_name}")
      elsif new_resource.policy_type != nil && "#{new_resource.policy_type.to_s}"=="rewrite"
        command = "bind lb vserver #{new_resource.name} -policyname #{new_resource.policy_name} -priority #{new_resource.policy_priority} -type #{new_resource.policy_flowtype.to_s} -gotoPriorityExpression #{new_resource.policy_goto_expression.to_s}"
        Chef::Log.info("Binding  LB vServer  #{new_resource.name} to policy #{new_resource.policy_name}")
      elsif new_resource.serviceorgroupname != nil
        command = "bind lb vserver #{new_resource.name}  #{new_resource.serviceorgroupname}"
        Chef::Log.info("Binding  LB vServer  #{new_resource.name} to service or group #{new_resource.serviceorgroupname}")
      elsif new_resource.certkey_name != nil
        command = "bind ssl vserver #{new_resource.name} -certkeyName #{new_resource.certkey_name}"
        Chef::Log.info("Binding  LB vServer  #{new_resource.name} to SSL certificate #{new_resource.certkey_name}")
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB vServer  #{new_resource.name} has been bound.")
      else
        Chef::Log.warn("Binding LB vServer  #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("LB vServer #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :unbind do
  # bind lb vserver $NAME $SERVERNAME $PORT
  if exists?
    begin
    Chef::Log.info("Unbinding  LB vServer  #{new_resource.name} on #{new_resource.ns_ip}")
      command = "unbind lb vserver #{new_resource.name}  #{new_resource.serviceorgroupname}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB vServer  #{new_resource.name} has been unbound from #{new_resource.server_name}")
      else
        Chef::Log.warn("Unbinding LB vServer  #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("LB vServer #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :remove do
  # rm LB vServer $NAME
  if exists?
    begin
      Chef::Log.info("Removing LB vServer  #{new_resource.name} from #{new_resource.ns_ip}")
      command = "remove lb vserver #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB vServer  #{new_resource.name} removed")
      else
        Chef::Log.warn("Remove of LB vServer #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("LB vServer  #{new_resource.name} doesn't exist on this netscaler")
  end
end

def load_current_resource
  @ns_service = Chef::Resource::NetscalerLbvserver.new(new_resource.name)
end

private
def ns
  @ns ||= begin
    connection = Net::SSH.start(
      @new_resource.ns_ip,
      @new_resource.ns_user,
      :password => @new_resource.ns_passwd)
    connection
  end
end

def exists?
  output = ns.exec!("show lb vserver #{@new_resource.name}")
  not_exists = output.include?('ERROR: No such resource')
  !not_exists
end

def enabled?
  output = ns.exec!("show lb vserver #{@new_resource.name}")
    if output.match('[^a-z]\sState: UP\n') !=nil
      enabled = true
    else
      enabled = false
    end
  enabled
end

def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
