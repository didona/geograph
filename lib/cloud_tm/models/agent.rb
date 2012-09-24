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

    def destroy
      #FIXME do proper destroy, when DML supports it
      manager.getRoot.removeAgents(self)
    end

    class << self

      def find_by_user(uid)
        agent = CloudTm::Agent.where(:user => uid).first

        unless agent
          raise Madmass::Errors::RollbackError.new("Agent for user #{uid} not found! Retrying.")
        end

        agent
      end

      def find(oid)
        _oid = oid #NOW IDS ARE STRINGS! .to_i
        all.each do |agent|
          return agent if agent.oid == _oid
        end
        return nil
      end


      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          manager.getRoot.add_agents instance
        end
      end

      alias_method_chain :create, :root

      def all
        manager.getRoot.getAgents
      end

    end
  end
end 