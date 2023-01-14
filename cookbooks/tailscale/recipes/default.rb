apt_update "update apt"

package "curl"

bash "add tailscale signingkey and repo" do
  code <<-BASH
  curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
  curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
  BASH
  action :nothing
  notifies :update, "apt_update[update apt]", :immediately
end

package "tailscale" do
  notifies :run, "bash[add tailscale signingkey and repo]", :before
end

service "tailscaled" do
  action [:start, :enable]
  notifies :run, "executep[tailscale up]", :immediately
end

file "#{ENV["HOME"]}/ts.key" do
  content node["tailscale"]["auth-key"]
end

execute "tailscale up" do
  command "sudo tailscale up --auth-key file:#{ENV["HOME"]}/ts.key"
  action :nothing
end