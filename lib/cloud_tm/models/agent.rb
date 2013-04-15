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

module CloudTm
  class Agent
    include Madmass::Agent::Executor
    include CloudTm::Model

    def attributes_to_hash
      { 
        :id => getExternalId,
        :status => status,
        :user => user
      }
    end

    def destroy
      domain_root.removeAgents(self)
    end

    class << self

      def factory attrs = {}
        agent_type = attrs.delete(:type)
        agent_klass = case agent_type
        when 'trackable'
          CloudTm::Trackable
        else
          CloudTm::Agent
        end
        agent_klass.create attrs
      end

      def create attrs = {}, &block
        instance = super
        domain_root.add_agents instance
        instance
      end


      def all
        domain_root.getAgents
      end

      def find_by_user(user)
        domain_root.getAgentsByUser(user)
      end

    end
  end
end 