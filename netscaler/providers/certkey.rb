
require 'net/ssh'

action :add do
  # add ssl certKey $NAME
  unless exists?
    begin
      Chef::Log.info("Adding certKey #{new_resource.name} on #{new_resource.ns_ip}")
      command = "add ssl certKey '#{new_resource.name}' -cert '#{new_resource.certpath}' -key '#{new_resource.keypath}' #{new_resource.password} -inform #{new_resource.certformat}"
      if new_resource.add_options != nil
          command <<  " #{new_resource.add_options} "
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("certKey #{new_resource.name} added")
      else
        Chef::Log.warn("Adding certKey #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("certKey #{new_resource.name} already exists")
  end
end

action :remove do
  # rm ssl certKey $NAME
  if exists?
    begin
      Chef::Log.info("Removing certKey #{new_resource.name} from #{new_resource.ns_ip}")
      command = "rm ssl certKey #{new_resource.name}"
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("certKey #{new_resource.name} removed")
      else
        Chef::Log.warn("Remove of certKey #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("certKey #{new_resource.name} doesn't exist on this netscaler")
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
  command = "show ssl certkey #{new_resource.name}"
  Chef::Log.info("command: #{command}")
  output = ns.exec!(command)
  not_exists = output.include?('ERROR: Certificate does not exist')
  !not_exists
end


def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
