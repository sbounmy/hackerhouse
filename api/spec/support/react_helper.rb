# RSpec.configure do |config|
#   config.before(:all, type: :feature) do
#     Capybara.server_port = 3000
#     React.server_port = Capybara.server_port + 1
#     Capybara.app_host = "http://localhost:#{React.server_port}"
#     ip = `/sbin/ip route|awk '/scope/ { print $9 }'`
#     ip = ip.gsub "\n", ""
#     require 'docker/compose'

#     # Create a new session in Dir.pwd using the file "docker-compose.yml".
#     # For fine-grained control over options, see Docker::Compose::Session#new
#     compose = Docker::Compose.new
#     puts Dir.pwd.inspect
#     compose.version

#     compose.up('app', detached:true)


#     # Process.spawn({"PORT" => React.server_port.to_s },
#     #   "/usr/local/bin/docker-compose run --rm app", chdir: '..').tap do |id|
#     #   parent = $$
#     #   at_exit {
#     #     Process.kill("KILL", id) if $$ == parent # Only if the parent process exits
#     #   }
#     # end if not React.run #hack to avoid running React server multiple times
#     # Timeout.timeout(60) do
#     #   print("Waiting for React app to spawn on http://#{ip}:#{React.server_port}")
#     #   until React.responsive? do
#     #     sleep(0.5)
#     #     print '.'
#     #   end
#     # end
#     # React.run = true
#   end
# end

# module React
#   extend ActiveSupport::Concern
#   class << self
#     attr_accessor :run, :server_port

#     def responsive?
#       # :todo: should have a /__identify__ endpoint and compare returned value
#       res = Net::HTTP.get_response URI("http://#{ip}:#{React.server_port}")
#       if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
#         return true
#       end
#     rescue Errno::ECONNREFUSED, Errno::EBADF
#       return false
#     end
#   end

# end