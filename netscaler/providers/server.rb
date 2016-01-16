
require 'net/ssh'

action :enable do
  #
  # enable server <serverName>
  #
  unless enabled?
    begin
      command = "enable server #{new_resource.name}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("server #{new_resource.name} enabled")
      else
        Chef::Log.warn("server #{new_resource.name} not enabled: #{output}")
      end
    ensure
      close
    end
  end
end

action :disable do
  # disable server  <serverName> [<delayInSeconds>] [-graceFul (YES|NO)]
  # show server <serverName>
  # Example
  # > disable server svr1 6000 -graceFul YES
  if disabled?
    Chef::Log.info("server #{new_resource.name} already disabled")
  else
    begin
      command = "disable server #{new_resource.name}"
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
        Chef::Log.info("server #{new_resource.name} disabled")
      else
        Chef::Log.warn("Disabling server #{new_resource.name} failed")
      end
    ensure
      close
    end   # begin
  end     # if enabled
end       # action


action :add do
  # add server <serverName> <serverIP>
  unless exists?
    begin
      Chef::Log.info("Adding server #{new_resource.name} on #{new_resource.ns_ip}")
      command = "add server #{new_resource.name}  #{new_resource.server_ip}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("server #{new_resource.name} added")
      else
        Chef::Log.warn("Adding server #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("server #{new_resource.name} already exists")
  end
end

action :remove do
  # rm server $NAME
  if exists?
    begin
      Chef::Log.info("Removing server #{new_resource.name} from #{new_resource.ns_ip}")
      command = "rm server #{new_resource.name}"

      output = @ns.exec!(command)

      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("server #{new_resource.name} removed")
      else
        Chef::Log.warn("Remove of server #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("server #{new_resource.name} doesn't exist on this netscaler")
  end
end


def load_current_resource
  @ns_service = Chef::Resource::NetscalerServer.new(new_resource.name)
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
  output = ns.exec!("show server #{@new_resource.name}")
  not_exists = output.include?('ERROR: No such resource')
  !not_exists
end

def enabled?
  output = ns.exec!("show server #{@new_resource.name}")
  enabled = output.include?("State:ENABLED")
  enabled
end
def disabled?
  output = ns.exec!("show server #{@new_resource.name}")
  disabled = output.include?("State:DISABLED")
  disabled
end

def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
