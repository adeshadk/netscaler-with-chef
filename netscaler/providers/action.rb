
require 'net/ssh'

action :add do
  # add [type] action <action_name> <rule> <action>
  unless exists?
    begin
      Chef::Log.info("Adding action #{new_resource.name} on #{new_resource.ns_ip}")
      if new_resource.action_type.to_s=="cs"
        if new_resource.action_targetvserverexpr != ""
          command = "add cs action  '#{new_resource.name}'  -targetVserverExpr '#{new_resource.action_targetvserverexpr}'"
        else
          command = "add cs action  '#{new_resource.name}'  -targetLBVserver '#{new_resource.action_targetvserver}'"
        end
      elsif  new_resource.action_type.to_s=="rewrite"
        command = "add rewrite action  '#{new_resource.name}' '#{new_resource.action_operation}' '#{new_resource.action_target}' '\"#{new_resource.action_value}\"' #{new_resource.add_options}"
      elsif  new_resource.action_type.to_s=="responder"
        if new_resource.action_htmlpage != nil
          command = "add responder action '#{new_resource.name}' '#{new_resource.action_operation}' '#{new_resource.action_htmlpage}' #{new_resource.add_options}"
        else
          command = "add responder action '#{new_resource.name}' '#{new_resource.action_operation}' '#{new_resource.action_target}' #{new_resource.add_options}"
        end
      end
      if new_resource.comment != nil
          command <<  " -comment '#{new_resource.comment}'"
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("action #{new_resource.name} added")
      else
        Chef::Log.warn("Adding action #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("action #{new_resource.name} already exist")
  end
end
action :set do
  # set [type] action <action_name> <rule> <action>
  if exists?
    begin
      Chef::Log.info("Adding action #{new_resource.name} on #{new_resource.ns_ip}")
      if new_resource.action_type.to_s=="cs"
        if new_resource.action_targetvserverexpr != ""
          command = "set cs action  '#{new_resource.name}'  -targetVserverExpr '#{new_resource.action_targetvserverexpr}'"
        else
          command = "set cs action  '#{new_resource.name}'  -targetLBVserver '#{new_resource.action_targetvserver}'"
        end
      elsif  new_resource.action_type.to_s=="rewrite"
        command = "set rewrite action  '#{new_resource.name}'  -target '#{new_resource.action_target}' -stringBuilderExpr '\"#{new_resource.action_value}\"'"
      elsif  new_resource.action_type.to_s=="responder"
        if new_resource.action_htmlpage != nil
          command = "set responder action '#{new_resource.name}'  -htmlpage '#{new_resource.action_htmlpage}'"
        else
          command = "set responder action '#{new_resource.name}'  -target '#{new_resource.action_target}'"
        end
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("action #{new_resource.name} updated")
      else
        Chef::Log.warn("updating action #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("action #{new_resource.name} does not exist")
  end
end
action :remove do
  # rm [type] action $NAME
  if exists?
    begin
      Chef::Log.info("Removing action #{new_resource.name} from #{new_resource.ns_ip}")
      if new_resource.action_type.to_s=="cs"
            command = "rm cs action #{new_resource.name}"
      elsif  new_resource.action_type.to_s=="rewrite"
            command = "rm rewrite action #{new_resource.name}"
      elsif  new_resource.action_type.to_s=="responder"
            command = "rm responder action #{new_resource.name}"
      end
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("action #{new_resource.name} removed")
      else
        Chef::Log.warn("remove of action #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("action #{new_resource.name} doesn't exist on this netscaler")
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
  if new_resource.action_type.to_s=="cs"
        command = "show cs action #{new_resource.name}"
  elsif  new_resource.action_type.to_s=="rewrite"
        command = "show rewrite action #{new_resource.name}"
  elsif  new_resource.action_type.to_s=="responder"
        command = "show responder action #{new_resource.name}"
  end
  Chef::Log.info("command: #{command}")
  output = ns.exec!(command)
  not_exists = output.include?('ERROR: Action does not exist')
  !not_exists
end


def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
