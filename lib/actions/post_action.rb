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


  # the action effects.
  def execute
    @geo_post = CloudTm::Post.create(
      :latitude => BigDecimal.new(@parameters[:latitude]),
      :longitude => BigDecimal.new(@parameters[:longitude]),
      :body => @parameters[:data][:body],
      :type => @parameters[:data][:type],
      :locality_key => CloudTm::Landmark.locality_key,
      :locality_value => CloudTm::Landmark.locality_value(@parameters[:latitude], @parameters[:longitude])
    )
    @agent.addPosts(@geo_post)
    CloudTm::Landmark.add_geo_object(@geo_post)
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :geo_agent => @agent.id,
      :geo_object => {
        :id => @geo_post.id,
        :latitude => @geo_post.latitude.to_s,
        :longitude => @geo_post.longitude.to_s,
        :data => {:body => @geo_post.body,
                  :type => @geo_post.type
        }
      }
    }

    Madmass.current_perception << p
  end

  def applicable?
    @agent = CloudTm::Trackable.find_by_user(@parameters[:user][:id])
    unless @agent
      why_not_applicable.publish(
        :name => :post_blog,
        :key => 'action.post.blog',
        :recipients => [@parameters[:user][:id]]
      )
    end
    return why_not_applicable.empty?
  end
end

