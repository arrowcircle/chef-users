include_recipe "sudo"

user node['users']['user'] do
  supports :manage_home => true
  comment "Rails production user"
  home "/home/#{node['users']['user']}"
  shell "/bin/bash"
  password (0...32).map{ ('a'..'z').to_a[rand(26)] }.join
  action :create
  not_if("ls /home | grep #{node['users']['user']}")
end

sudo_group = "sudo"

group sudo_group do
  action :modify
  members node['users']['user']
end

group sudo_group do
  action :modify
  members "vagrant"
  append true
  only_if ("ls /home | grep vagrant")
end

execute "generate ssh key for user" do
  user node['users']['user']
  command "ssh-keygen -t rsa -q -f /home/#{node['users']['user']}/.ssh/id_rsa -P \"\""
  not_if { File.exists?("/home/#{node['users']['user']}/.ssh/id_rsa") }
end

template "/home/#{node['users']['user']}/.ssh/authorized_keys" do
  user node['users']['user']
  owner node['users']['user']
  source "keys.erb"
  mode 0600
  variables({:keys => node["users"]["authorized_keys"]})
end

template "/home/#{node['users']['user']}/.ssh/known_hosts" do
  user node['users']['user']
  owner node['users']['user']
  source "keys.erb"
  mode 0600
  variables({:keys => node["users"]["known_hosts"]})
end