
require 'net/ssh'

action :add do
  # add policy patset <name>
  unless exists?
    begin
      Chef::Log.info("Adding patternset #{new_resource.name} on #{new_resource.ns_ip}")
      command = "add policy patset '#{new_resource.name}'"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Patternset #{new_resource.name} added")
      else
        Chef::Log.warn("Adding patternset #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Patternset #{new_resource.name} already exists")
  end
end

action :bind do
  #bind policy patset <name> <pattern> [-index <indexvalue>]
  if exists?
    begin
      Chef::Log.info("Binding patternset #{new_resource.name} on #{new_resource.ns_ip} to #{new_resource.pattern}")
      command = "bind policy patset '#{new_resource.name}' '#{new_resource.pattern}'"
      if new_resource.index != nil
        command << " -index #{new_resource.index}"
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Pattern #{new_resource.pattern} bound to  patternset #{new_resource.name}.")
      else
        Chef::Log.warn("Binding pattern #{new_resource.pattern} to patternset #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Patternset #{new_resource.name} does not exist.")
  end
end

action :unbind do
  #unbind policy patset <name> <pattern>
  if exists?
    begin
      Chef::Log.info("Unbinding patternset #{new_resource.name} on #{new_resource.ns_ip} from #{new_resource.pattern}")
      command = "unbind policy patset '#{new_resource.name}' '#{new_resource.pattern}'"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Pattern #{new_resource.pattern} unbound from patternset #{new_resource.name}.")
      else
        Chef::Log.warn("Unbinding pattern #{new_resource.pattern} from patternset #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Patternset #{new_resource.name} does not exist.")
  end
end

action :remove do
  # rm policy patset $NAME
  if exists?
    begin
      Chef::Log.info("Removing patternset #{new_resource.name} from #{new_resource.ns_ip}")
      command = "rm policy patset #{new_resource.name}"
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("Patternset #{new_resource.name} removed")
      else
        Chef::Log.warn("Remove of patternset #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("patternset #{new_resource.name} doesn't exist on this netscaler")
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
  command = "show policy patset #{new_resource.name}"
  Chef::Log.info("command: #{command}")
  output = ns.exec!(command)
  not_exists = output.include?('ERROR: Dataset/Patset does not exist')
  !not_exists
end


def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
