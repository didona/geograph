# This script given a host name of the mod cluster node node and generates an appropriate httpd.conf file.
host = %x(hostname).gsub("\n", '')
ip=%x(ifconfig eth0 | grep inet | grep -v inet6 | cut -d ":" -f 2 | cut -d " " -f 1).gsub("\n", '')
puts "start setting rhq host with arguments #{host} ..."


HOST_PLACEHOLDER = "{THIS_HOST}"
IP_PLACEHOLDER   = "{THIS_IP}"


source_root = "/opt/rhq/rhq-agent/conf/"
current_path = File.dirname(File.expand_path(__FILE__))

# path to the httpd.conf configuration file to replace
rhq_agent_conf = File.join("#{source_root}", 'agent-configuration.xml')

# path to the httpd.conf template file

rhq_agent_conf_template = File.join("#{current_path}", 'templates', 'agent-configuration.xml.rhq.template')


# open the template file, replace the HOST_PLACEHOLDER with the host argument and override the original conf file
File.open(rhq_agent_conf_template, 'r') do |template|
  rhq_agent_conf_data = template.read.gsub(HOST_PLACEHOLDER, host).gsub(IP_PLACEHOLDER,ip)

  File.open(
    rhq_agent_conf, 'w') do |original|
    original.write rhq_agent_conf_data
  end
end

puts "rhq agent cluster host set!"