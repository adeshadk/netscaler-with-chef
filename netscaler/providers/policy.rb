
require 'net/ssh'

action :add do
  # add [type] policy <policy_name> <rule> <action>
  unless exists?
    begin
      Chef::Log.info("Adding policy #{new_resource.name} on #{new_resource.ns_ip}")
      if new_resource.policy_type.to_s=="cs"
        if new_resource.policy_action != nil   #if action is defined
          command = "add cs policy  '#{new_resource.name}'  -rule '#{new_resource.policy_rule}' -action '#{new_resource.policy_action}' "
        else #if no action defined but a target lb is provided at binding time
          command = "add cs policy  '#{new_resource.name}'  -rule '#{new_resource.policy_rule}' "
        end
      elsif  new_resource.policy_type.to_s=="rewrite"
        command = "add rewrite policy  '#{new_resource.name}' '#{new_resource.policy_rule}' '#{new_resource.policy_action}' -comment '#{new_resource.comment}'"
      elsif  new_resource.policy_type.to_s=="responder"
        command = "add responder policy '#{new_resource.name}'  '#{new_resource.policy_rule}' '#{new_resource.policy_action}' -comment '#{new_resource.comment}'"
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("policy #{new_resource.name} added")
      else
        Chef::Log.warn("Adding policy #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("policy #{new_resource.name} already exists")
  end
end
action :set do
  # set [type] policy <policy_name> <rule> <action>
  if exists?
    begin
      Chef::Log.info("Adding policy #{new_resource.name} on #{new_resource.ns_ip}")
      if new_resource.policy_type.to_s=="cs"
        command = "set cs policy  '#{new_resource.name}'  -rule '#{new_resource.policy_rule}' -action '#{new_resource.policy_action}' "
      elsif  new_resource.policy_type.to_s=="rewrite"
        command = "set rewrite policy  '#{new_resource.name}' -rule '#{new_resource.policy_rule}' -action '#{new_resource.policy_action}' "
      elsif  new_resource.policy_type.to_s=="responder"
        command = "set responder policy '#{new_resource.name}' -rule '#{new_resource.policy_rule}'  -action '#{new_resource.policy_action}' "
      end
      Chef::Log.info("Command: #{command}")
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("policy #{new_resource.name} updated")
      else
        Chef::Log.warn("Updating policy #{new_resource.name} failed: #{output}")
      end
    ensure
      close
    end
  else
    Chef::Log.info("policy #{new_resource.name} doesn't exist on this netscaler")
  end
end
action :remove do
  # rm [type] policy $NAME
  if exists?
    begin
      Chef::Log.info("Removing policy #{new_resource.name} from #{new_resource.ns_ip}")
      if new_resource.policy_type.to_s=="cs"
            command = "rm cs policy #{new_resource.name}"
      elsif  new_resource.policy_type.to_s=="rewrite"
            command = "rm rewrite policy #{new_resource.name}"
      elsif  new_resource.policy_type.to_s=="responder"
            command = "rm responder policy #{new_resource.name}"
      end
      output = @ns.exec!(command)
      status = output.include?("ERROR:")
      if !status
        Chef::Log.info("policy #{new_resource.name} removed")
      else
        Chef::Log.warn("remove of policy #{new_resource.name} failed: #{output}")
      end

    ensure
      close
    end
  else
    Chef::Log.info("policy #{new_resource.name} doesn't exist on this netscaler")
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
  if new_resource.policy_type.to_s=="cs"
        command = "show cs policy #{new_resource.name}"
  elsif  new_resource.policy_type.to_s=="rewrite"
        command = "show rewrite policy #{new_resource.name}"
  elsif  new_resource.policy_type.to_s=="responder"
        command = "show responder policy #{new_resource.name}"
  end
  Chef::Log.info("command: #{command}")
  output = ns.exec!(command)
  not_exists = output.include?('ERROR: No such policy exists')
  !not_exists
end


def close
  output = @ns.exec("save config")
  @ns.close rescue nil
  @ns = nil
end
