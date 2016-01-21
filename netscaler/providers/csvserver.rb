
require 'net/ssh'

action :enable do
  # enable cs vserver <cs ververName>
  unless enabled?
    begin
      command = "enable cs vserver #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("CS vServer #{new_resource.name} enabled")
      else
        Chef::Log.warn("CS vServer #{new_resource.name} not enabled: #{output}")
      end
    ensure
      close
    end
  end
end

action :disable do
  # disable cs vserver <cs vserverName>
  if enabled?
    begin
      command = "disable cs vserver #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("CS vServer #{new_resource.name} disabled")
      else
        Chef::Log.warn("Disabling CS vServer #{new_resource.name} failed")
      end
    ensure
      close
    end   # begin
  else
    Chef::Log.info("CS vServer #{new_resource.name} already disabled")
  end     # if enabled
end       # action

  # add cs vserver <CS vServerName>
  # Example
  # > add cs vserver cs-www.anysite.com_80 6000 -graceFul YES
action :add do
  # add CS vServer $NAME HTTP
  unless exists?
    begin
      Chef::Log.info("Adding CS vServer #{new_resource.name} on #{new_resource.csvserver_ip}")
      command = "add cs vserver #{new_resource.name} #{new_resource.csvserver_protocol} #{new_resource.csvserver_ip} #{new_resource.csvserver_port}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("CS vServer #{new_resource.name} added")
      else
        Chef::Log.warn("Adding CS vServer #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("CS vServer #{new_resource.name} already exists")
  end
end
action :set do
  # set CS vServer $NAME [options]
  if exists?
    begin
      Chef::Log.info("Setting CS vServer #{new_resource.name} on #{new_resource.ns_ip}")
      command = "set cs vserver #{new_resource.name} "
      if new_resource.csvserver_ip != nil
          command << " -IPAddress #{new_resource.csvserver_ip} "
      end
      if new_resource.set_options
        command << "  #{new_resource.set_options} "
      end
		#Setting comments
        command << " -comment 'CS vServer for #{new_resource.name}'"

      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("CS vServer #{new_resource.name} has been set")
      else
        Chef::Log.warn("Setting CS vServer #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("CS vServer #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :bind do
  # bind CS vServer $NAME -policyname $policyname -priority $priority
  if exists?
    begin
	  Chef::Log.info("Binding  Server #{new_resource.name}")
      if  new_resource.policy_type != nil && "#{new_resource.policy_type.to_s}"=="cs"
          if new_resource.policy_target_lbvserver != nil
            command = "bind cs vserver #{new_resource.name} -policyname #{new_resource.policy_name} -priority #{new_resource.policy_priority} -targetLBVserver  #{new_resource.policy_target_lbvserver}"
          else
            command = "bind cs vserver #{new_resource.name} -policyname #{new_resource.policy_name} -priority #{new_resource.policy_priority}"
          end
      elsif new_resource.policy_type != nil && "#{new_resource.policy_type.to_s}"=="responder"
        command = "bind cs vserver #{new_resource.name} -policyname #{new_resource.policy_name} -priority #{new_resource.policy_priority}"
      elsif new_resource.policy_type != nil && "#{new_resource.policy_type.to_s}"=="rewrite"
        command = "bind cs vserver #{new_resource.name} -policyname #{new_resource.policy_name} -priority #{new_resource.policy_priority} -type #{new_resource.policy_flowtype.to_s} -gotoPriorityExpression #{new_resource.policy_goto_expression.to_s}"
      elsif new_resource.default_lbvserver != nil
        command = "bind cs vserver #{new_resource.name} -lbvserver #{new_resource.default_lbvserver}"
      elsif new_resource.certkey_name != nil
        command = "bind ssl vserver #{new_resource.name} -certkeyName #{new_resource.certkey_name}"
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        if new_resource.default_lbvserver != nil
          Chef::Log.info("CS vServer #{new_resource.name} has been bound to default vserver #{new_resource.default_lbvserver}")
        else
          Chef::Log.info("CS vServer #{new_resource.name} has been bound to policy #{new_resource.policy_name}")
        end
      else
        Chef::Log.warn("Binding CS vServer #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("CS vServer #{new_resource.name} doesn't exist on this netscaler")
  end
end


action :remove do
  # rm CS vServer $NAME
  if exists?
    begin
      Chef::Log.info("Removing CS vServer #{new_resource.name} from #{new_resource.ns_ip}")
      command = "rm cs vserver #{new_resource.name}"

      output = @ns.exec!(command)

      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("CS vServer #{new_resource.name} removed")
      else
        Chef::Log.warn("Remove of CS vServer #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("CS vServer #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :barf do
  if enabled?
    begin
      Chef::Log.info("This CS vServer is totally enabled")
    ensure
      close
    end
  else
    begin
      Chef::Log.info("This CS vServer is disabled, yo!")
    ensure
      close
    end
  end
end

def load_current_resource
  @ns_service = Chef::Resource::NetscalerCsvserver.new(new_resource.name)
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
  output = ns.exec!("show cs vserver #{@new_resource.name}")
  not_exists = output.include?('ERROR: No such resource')
  !not_exists
end

def enabled?
  output = ns.exec!("show cs vserver #{@new_resource.name}")
  enabled = output.include?("State: UP")
  enabled
end

def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
