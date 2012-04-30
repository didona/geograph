###############################################################################
###############################################################################
#
# This file is part of GeoGraph.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################

#begin
#  require File.join(Rails.root, 'lib', 'cloud_tm', 'framework')
#
#  #Configure jgroups to use the gossip router
#  #Note: The gossip router is in the users db
#
#
#  jgroups_conf_dir = File.join(Rails.root, "lib", "fenix","conf")
#  # open the template file, replace the GOSSIP_ROUTER_PLACEHOLDER right value
#  puts "********************** JGROUPS CONF DIR :  #{jgroups_conf_dir}"
#  puts "********************** MaDMASS : "
#  puts "********************** INSTALL OPTIONS : #{Madmass.install_options(:cluster_nodes).inspect}}"
#  jgossip_address = "#{Madmass.install_options(:cluster_nodes)[:db_nodes].first}[12001]"
#  puts "********************** JGROUPS GOSSIP ADDR :  #{jgossip_address}"
#  File.open(File.join(jgroups_conf_dir,"jgroups.xml.template"), 'r') do |template|
#    jgroups_conf = template.read.gsub("{GOSSIP_ROUTER_PLACEHOLDER}", jgossip_address)
#    puts "changing JGROUPS addres to :  #{jgossip_address}"
#    File.open(File.join(jgroups_conf_dir,"jgroups.xml"), 'w') do |original|
#      original.write jgroups_conf
#    end
#  end
#
#
#  # loading the Fenix Framework
#  CloudTm::Framework.init(
#    :dml => 'geograph.dml',
#    :conf => 'infinispan-conf.xml',
#    :framework => CloudTm::Config::Framework::ISPN
#  )
#rescue Exception => ex
#  Rails.logger.error "Cannot load Cloud-TM Framework: #{ex}"
#end