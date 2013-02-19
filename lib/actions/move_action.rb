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


# This file is the implementation of the  MoveAction.
# The implementation must comply with the action definition pattern
# that is briefly described in the Madmass::Action::Action class.

module Actions
  class MoveAction < Madmass::Action::Action
    action_params :user, :latitude, :longitude, :data
    #action_states :none
    #next_state :none

    # [OPTIONAL]  Add your initialization code here.
    def initialize params
      super
      # uncomment this to communicate via web sockets
      #@channels << :all

    end


    # [MANDATORY] Override this method in your action to define
    # the action effects.
    def execute
      Madmass.logger.debug("Executing move action with parameters #{@parameters.inspect}")


      @agent =  CloudTm::FenixFramework.getDomainRoot().getApp().getAgentsByUser(@parameters[:user][:id])



      @agent.update_attributes(
        :latitude => java.math.BigDecimal.new(@parameters[:latitude]),
        :longitude => java.math.BigDecimal.new(@parameters[:longitude]),
        :body => @parameters[:data][:body],
        :type => @parameters[:data][:type]
      )

      @agent.compute_neighbours "action"

    end

    # the perception content.
    def build_result
      p = Madmass::Perception::Percept.new(self)
      p.data = {
        :geo_agent => @agent.getExternalId,
        :geo_object => {
          :id => @agent.getExternalId,
          :latitude => @agent.latitude.to_s,
          :longitude => @agent.longitude.to_s,
          :data => {:body => @agent.body,
                    :type => @agent.type}
        }
      }

      edges = @agent.edges_for_percept "action"
      p.data[:edges] = edges if edges


      Madmass.current_perception = []
      Madmass.current_perception << p
    end


  end

end
