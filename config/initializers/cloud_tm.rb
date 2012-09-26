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
begin
  require File.join(Rails.root, 'lib', 'cloud_tm', 'framework')

  # loading the Fenix Framework
  Madmass.logger.debug "[initializers/cloud_tm] Initializing Framework"
  CloudTm::Framework.init(
    :dml => 'geograph.dml',
    :conf => 'infinispan-udp-conf-geograph.xml',
    :framework => CloudTm::Config::Framework::ISPN
  )
rescue Exception => ex
  Rails.logger.error "Cannot load Cloud-TM Framework: #{ex}"
  Rails.logger.error "\n #{ex.backtrace.join("\n\t")}"
  if(defined?(ex.cause))
    Rails.logger.error "Cause: #{ex.cause}"
    Rails.logger.error "\n #{ex.cause.backtrace.join("\n\t")}" if ex.cause
  end
end