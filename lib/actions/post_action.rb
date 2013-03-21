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


# This file is the implementation of the  PostAction.
# The implementation must comply with the action definition pattern
# that is briefly described in the Madmass::Action::Action class.


class Actions::PostAction < Madmass::Action::Action
  action_params :latitude, :longitude, :data, :user

  # [OPTIONAL]  Add your initialization code here.
  def initialize params
    super
    @geo_post = nil
    # uncomment this to communicate via web sockets
    #@channels << :all
  end


  # the action effects.
  def execute
    @agent = CloudTm::FenixFramework.getDomainRoot().getApp().getAgentsByUser(@parameters[:user][:id])
    # FIXME: put this control in the applicable? pattern
    if @agent
      @geo_post = CloudTm::Post.create
      @geo_post.update_attributes(
        :latitude => BigDecimal.new(@parameters[:latitude]),
        :longitude => BigDecimal.new(@parameters[:longitude]),
        :body => @parameters[:data][:body],
        :type => @parameters[:data][:type]
      )
      @agent.addPosts(@geo_post)
      CloudTm::Landmark.add_geo_object(@geo_post)
    end
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :geo_agent => @agent.getExternalId,
      :geo_object => {
        :id => @geo_post.getExternalId,
        :latitude => @geo_post.latitude.to_s,
        :longitude => @geo_post.longitude.to_s,
        :data => {:body => @geo_post.body,
                  :type => @geo_post.type
        }
      }
    }

    if @geo_post
      edges = @geo_post.edges_for_percept "action"
      p.data[:edges] = edges if edges
    end


    Madmass.current_perception = []
    Madmass.current_perception << p
  end


end

