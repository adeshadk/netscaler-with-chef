
require 'net/ssh'

action :enable do
  # enable service service-name
  unless enabled?
    begin
      command = "enable service #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Service #{new_resource.name} enabled")
      else
        Chef::Log.warn("Service #{new_resource.name} not enabled: #{output}")
      end
    ensure
      close
    end
  end
end

action :disable do
  # disable service <serviceName> [<delayInSeconds>] [-graceFul (YES|NO)]
  # Example
  # > disable service svc1 5 -graceFul YES
  if enabled?
    begin
      command = "disable service #{new_resource.name}"
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
        Chef::Log.info("Service #{new_resource.name} disabled")
      else
        Chef::Log.warn("Disabling service #{new_resource.name} failed")
      end
    ensure
      close
    end   # begin
  else
    Chef::Log.info("Service #{new_resource.name} already disabled")
  end
end


action :add do
  # add service $NAME $IP HTTP $PORT [options]
  unless exists?
    begin
      Chef::Log.info("Adding service #{new_resource.name} on #{new_resource.ns_ip}")
      command = "add service #{new_resource.name} #{new_resource.service_member_name} #{new_resource.protocol_type} #{new_resource.service_member_port}"
      if new_resource.add_options
        command << " #{new_resource.add_options}"
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Service #{new_resource.name} added")
      else
        Chef::Log.warn("Add of service #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Service #{new_resource.name} already exists")
  end
end

action :set do
  # set service $NAME [options]
  if exists?
    begin
      Chef::Log.info("Set service #{new_resource.name} on #{new_resource.ns_ip}")
      command = "set service #{new_resource.name} "
      if new_resource.set_options
        command << " #{new_resource.set_options} "
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Service #{new_resource.name} settings changed.")
      else
        Chef::Log.warn("Set of service #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Service #{new_resource.name} already exists")
  end
end

action :remove do
  # remove service $NAME
  if exists?
    begin
      Chef::Log.info("Removing service #{new_resource.name} from #{new_resource.ns_ip}")
      command = "rm service #{new_resource.name}"
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Service #{new_resource.name} removed")
      else
        Chef::Log.warn("Removal of service #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Service #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :bindmonitor do
  # bind lb monitor $MONITOR_NAME $NAME
  if exists?
    begin

    Chef::Log.info("LB Monitor #{new_resource.monitor_name} is being bound to service #{new_resource.name}")
      command = "bind lb monitor #{new_resource.monitor_name}  #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB Monitor #{new_resource.monitor_name} is bound to service #{new_resource.name} successfully.")
      else
        Chef::Log.warn("Binding LB Monitor #{new_resource.monitor_name} to service #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Service #{new_resource.name} doesn't exist on this netscaler")
  end
end

action :unbindmonitor do
  # unbind lb monitor $MONITOR_NAME $NAME
  if exists?
    begin

    Chef::Log.info("LB Monitor #{new_resource.monitor_name} is being unbound from service #{new_resource.name}")
      command = "unbind lb monitor #{new_resource.monitor_name}  #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("LB Monitor #{new_resource.monitor_name} is unbound from service #{new_resource.name} successfully.")
      else
        Chef::Log.warn("Unbinding LB Monitor #{new_resource.monitor_name} from service #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Service #{new_resource.name} doesn't exist on this netscaler")
  end
end

def load_current_resource
  @ns_service = Chef::Resource::NetscalerService.new(new_resource.name)
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
  output = ns.exec!("show service #{@new_resource.name}")
  exists = output.include?(@new_resource.name)
  exists
end

def enabled?
  output = ns.exec!("show service #{@new_resource.name}")
  disabled = output.include?("State: OUT OF SERVICE")
  !disabled
end

def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
