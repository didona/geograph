ip=%x(ifconfig eth0 | grep inet | grep -v inet6 | cut -d ":" -f 2 | cut -d " " -f 1).gsub("\n", '')
puts "jboss configured with #{ip} ..."


IP_PLACEHOLDER   = "{THIS_IP}"


source_root = "/opt/torquebox/current/jboss/bin/"
current_path = File.dirname(File.expand_path(__FILE__))

# path to the standalone.conf configuration file to replace

jboss_conf = File.join("#{source_root}", 'standalone.conf')

# path to the standalone.conf template file

jboss_conf_template = File.join("#{current_path}", 'templates', 'standalone.conf.template')


# open the template file, replace the HOST_PLACEHOLDER with the host argument and override the original conf file
File.open(jboss_conf_template, 'r') do |template|
jboss_conf_data = template.read.gsub(IP_PLACEHOLDER,ip)

  File.open(
    jboss_conf, 'w') do |original|
    original.write jboss_conf_data
  end
end

puts "jboss conf set!"