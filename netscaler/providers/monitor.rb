
require 'net/ssh'

action :add do
  # add lb monitor <name> <type> [options]
  unless exists?
    begin
      Chef::Log.info("Adding monitor #{new_resource.name} on #{new_resource.ns_ip}")
      command = "add lb monitor '#{new_resource.name}' '#{new_resource.type}' "
        if new_resource.send_string != nil && new_resource.send_string !=""
          command << " -send '#{new_resource.send_string}' "
        end
        if new_resource.recv_string != nil && new_resource.recv_string !=""
          command << " -recv '#{new_resource.recv_string}' "
        end
        if new_resource.custom_headers != nil && new_resource.custom_headers !=""
          command << " -customHeaders '#{new_resource.custom_headers}' "
        end
        if new_resource.http_request != nil && new_resource.http_request !=""
          command << " -httpRequest '#{new_resource.http_request}' "
        end
        if new_resource.response_codes != nil && new_resource.response_codes !=""
          command << " -respCode #{new_resource.response_codes} "
        end
        #if monitor type is MSSQL-ECV
        if new_resource.type.to_s.downcase =="mssql-ecv"
            command <<  " -userName '#{new_resource.db_user}' -database '#{new_resource.db_name}' -sqlQuery '#{new_resource.db_query}' -evalRule '#{new_resource.db_eval_rule}' "
        end
      command << " #{new_resource.add_options} #{new_resource.options}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("monitor #{new_resource.name} added")
      else
        Chef::Log.warn("Adding monitor #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("monitor #{new_resource.name} already exists")
  end
end

action :set do
  #set lb monitor <name> <type> [options]
  if exists?
    begin
      Chef::Log.info("Set monitor #{new_resource.name} on #{new_resource.ns_ip} ")
      command = "set lb monitor '#{new_resource.name}' '#{new_resource.type}' "
        if new_resource.send_string != nil && new_resource.send_string !=""
          command << " -send '#{new_resource.send_string}' "
        end
        if new_resource.recv_string != nil && new_resource.recv_string !=""
          command << " -recv '#{new_resource.recv_string}' "
        end
        if new_resource.custom_headers != nil && new_resource.custom_headers !=""
          command << " -customHeaders '#{new_resource.custom_headers}' "
        end
        if new_resource.http_request != nil && new_resource.http_request !=""
          command << " -httpRequest '#{new_resource.http_request}' "
        end
        if new_resource.response_codes != nil && new_resource.response_codes !=""
          command << " -respCode #{new_resource.response_codes} "
        end
        #if monitor type is MSSQL-ECV
        if new_resource.type.to_s =="mssql-ecv"
            command <<  " -userName '#{new_resource.db_user}' -database '#{new_resource.db_name}' -sqlQuery '#{new_resource.db_query}' -evalRule '#{new_resource.db_eval_rule}' "
        end

        command << " #{new_resource.set_options} #{new_resource.options}"
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("monitor #{new_resource.name} updated")
      else
        Chef::Log.warn("monitor #{new_resource.name} failed to update: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("Monitor #{new_resource.name} does not exist.")
  end
end

action :remove do
  # rm monitor $NAME
  if exists?
    begin
      Chef::Log.info("Removing monitor #{new_resource.name} from #{new_resource.ns_ip}")
      command = "rm monitor #{new_resource.name}  '#{new_resource.type}'"
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("monitor #{new_resource.name} removed")
      else
        Chef::Log.warn("Remove of monitor #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("monitor #{new_resource.name} doesn't exist on this netscaler")
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
  command = "show monitor #{new_resource.name}"
  Chef::Log.info("command: #{command}")
  output = ns.exec!(command)
  not_exists = output.include?('ERROR: No such resource')
  !not_exists
end


def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
