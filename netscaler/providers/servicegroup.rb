
require 'net/ssh'

action :enable do
  # Enables a specific servicegroup
  # enable servicegroup <Servicegroup Name>
  # Example
  # enable servicegroup env01_site.com

  unless enabled?
    begin
      command = "enable servicegroup #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Servicegroup #{new_resource.name} enabled")
      else
        Chef::Log.warn("Servicegroup #{new_resource.name} not enabled: #{output}")
      end
    ensure
      close
    end
  end
end

action :disable do
  # Disables a specific servicegroup
  # disable servicegroup  <serviceName> [<delayInSeconds>] [-graceFul (YES|NO)]
  # Example
  # > disable servicegroup env01_site.com 6000 -graceFul YES

  if enabled?
    begin
      command = "disable servicegroup #{new_resource.name}"
      if new_resource.disable_timeout > 0
        command << " #{new_resource.disable_timeout}"
      end

      if new_resource.disable_graceful
        command << " -graceFul YES"
      else
        command << " -graceFul NO"
      end

      Chef::Log.info("Command: #{command}")

      output = @ns.exec!(command)

      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Servicegroup #{new_resource.name} disabled")
      else
        Chef::Log.warn("Disabling servicegroup #{new_resource.name} failed")
      end
    ensure
      close
    end   # begin
  else
    Chef::Log.info("Servicegroup #{new_resource.name} already disabled")
  end     # if enabled
end       # action


action :add do
  # Adds a specific servicegroup
  # add servicegroup $NAME HTTP
  # Example
  # add servicegroup env01_site.com HTTP
  unless exists?
    begin
      Chef::Log.info("Adding servicegroup #{new_resource.name} on #{new_resource.ns_ip}")
      command = "add servicegroup #{new_resource.name}  #{new_resource.protocol_type} "
      if new_resource.add_options
        command << " #{new_resource.add_options} "
      end
    #Setting comments
        command << " -comment 'Servicegroup for environment #{new_resource.name.partition("-")[0]} for  #{new_resource.name.partition("-")[2]} web service/site'"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Servicegroup #{new_resource.name} added")
      else
        Chef::Log.warn("Adding servicegroup #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Servicegroup #{new_resource.name} already exists")
  end
end
action :set do
  # Sets a specific servicegroup
  # set servicegroup $NAME [options]
  # Example
  # set servicegroup env01_site.com   -cip ENABLED CLIENT-IP  -sp ON -downStateFlush ENABLED
  if exists?
    begin
      Chef::Log.info("Setting servicegroup #{new_resource.name} on #{new_resource.ns_ip}")
      command = "set servicegroup #{new_resource.name} "

      if new_resource.set_options
        command << " #{new_resource.set_options} "
      end
		#Setting comments
        command << " -comment 'Servicegroup for environment #{new_resource.name.partition("-")[0]} for  #{new_resource.name.partition("-")[2]} web service/site'"

      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Servicegroup #{new_resource.name} has been set")
      else
        Chef::Log.warn("Setting servicegroup #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Servicegroup #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :bind do
  # bind servicegroup $NAME $SERVERNAME $PORT
  if exists?
    begin

	  Chef::Log.info("Binding  server  #{new_resource.servicegroup_member_name} to servicegroup #{new_resource.name} ")
      command = "bind servicegroup #{new_resource.name} #{new_resource.servicegroup_member_name} #{new_resource.servicegroup_member_port}"

      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Servicegroup #{new_resource.name} has been bound to #{new_resource.servicegroup_member_name}")
      else
        Chef::Log.warn("Binding servicegroup #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("Servicegroup #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :unbind do
  # bind servicegroup $NAME $SERVERNAME $PORT
  if exists?
    begin

    Chef::Log.info("Unbinding  server  #{new_resource.servicegroup_member_name} from servicegroup  #{new_resource.name} ")
      command = "unbind servicegroup #{new_resource.name} #{new_resource.servicegroup_member_name} #{new_resource.servicegroup_member_port}"

      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Servicegroup #{new_resource.name} has been unbound from #{new_resource.servicegroup_member_name}")
      else
        Chef::Log.warn("Unbinding servicegroup #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("Servicegroup #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :remove do
  # rm servicegroup $NAME
  if exists?
    begin
      Chef::Log.info("Removing servicegroup #{new_resource.name} from #{new_resource.ns_ip}")
      command = "rm servicegroup #{new_resource.name}"

      output = @ns.exec!(command)

      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Servicegroup #{new_resource.name} removed")
      else
        Chef::Log.warn("Removal of servicegroup #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("Servicegroup #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :bindmonitor do
  # bind lb monitor $MONITOR_NAME $NAME
  if exists?
    begin

    Chef::Log.info("LB Monitor #{new_resource.monitor_name} is being bound to servicegroup #{new_resource.name}")
      command = "bind lb monitor #{new_resource.monitor_name}  #{new_resource.name}"

      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB Monitor #{new_resource.monitor_name} is bound to servicegroup #{new_resource.name} successfully.")
      else
        Chef::Log.warn("Binding LB Monitor #{new_resource.monitor_name} to servicegroup #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("Servicegroup #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :unbindmonitor do
  # unbind lb monitor $MONITOR_NAME $NAME
  if exists?
    begin

    Chef::Log.info("LB Monitor #{new_resource.monitor_name} is being unbound from servicegroup #{new_resource.name}")
      command = "unbind lb monitor #{new_resource.monitor_name}  #{new_resource.name}"

      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB Monitor #{new_resource.monitor_name} is unbound from servicegroup #{new_resource.name} successfully.")
      else
        Chef::Log.warn("Unbinding LB Monitor #{new_resource.monitor_name} from servicegroup #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("Servicegroup #{new_resource.name} doesn't exist on this netscaler")
  end
end

def load_current_resource
  @ns_service = Chef::Resource::NetscalerServicegroup.new(new_resource.name)
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
  output = ns.exec!("show servicegroup #{@new_resource.name}")
  not_exists = output.include?('ERROR: No such resource')
  !not_exists
end

def enabled?
  output = ns.exec!("show servicegroup #{@new_resource.name}")
  if output.match('[^a-z]\sState: ENABLED\s*Effective State: UP\s') !=nil
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
