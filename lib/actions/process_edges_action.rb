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

require 'haversine_distance'

# This file is the implementation of the  MoveAction.
# The implementation must comply with the action definition pattern
# that is briefly described in the Madmass::Action::Action class.

module Actions
  class ProcessEdgesAction < Madmass::Action::Action
    #action_params :distance
    #action_states :none
    #next_state :none

    def initialize params
      super
      #@channels << :all
    end


    # [MANDATORY] Override this method in your action to define
    # the action effects.
    def execute
      @edges = []
      geo_objects = CloudTm::GeoObject.all
      geo_objects.each_with_index do |geo_object, index|
        geo_object.compute_neighbours "job" #FIXME (pass index)
        neighbours = geo_object.edges_for_percept "job"
        @edges += neighbours if neighbours
        # remove previous edges
        #geo_object1.remove_edges
        # connect edges
        #geo_objects.to_a[(index+1)..-1].each do |geo_object2|
        #  if HaversineDistance.calculate(geo_object1, geo_object2) <= 1000 #FIXME@job.distance
        #    geo_object1.addIncoming(geo_object2)
        #    geo_object2.addIncoming(geo_object1)
        #    @edges << [geo_object1, geo_object2]
        #  end
        #end
      end
    end

    # [MANDATORY] Override this method in your action to define
    # the perception content.
    def build_result
      p = Madmass::Perception::Percept.new(self)
#      p.add_headers({:topics => ['all']}) #who must receive the percept
      p.data = {:edges => @edges} unless @edges.blank?
      Madmass.current_perception = []
      Madmass.current_perception << p
    end

    # [OPTIONAL] - The default implementation returns always true
    # Override this method in your action to define when the action is
    # applicable (i.e. to verify the action preconditions).
    #def applicable?
    # true
    #end

    # [OPTIONAL] Override this method to add parameters preprocessing code
    # The parameters can be found in the @parameters hash
    # def process_params
    #   puts "Implement me!"
    # end

    private


  end

end
