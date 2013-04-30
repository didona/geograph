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


class Actions::LikePostAction < Madmass::Action::Action
  action_params :latitude, :longitude, :user

  def initialize params
    super
  end

  def execute
    lat = BigDecimal.new(@parameters[:latitude])
    lon  = BigDecimal.new(@parameters[:longitude])
    landmark = CloudTm::PostLandmark.find_by_coordinates(lat, lon)
    if landmark and landmark.locations and landmark.locations.size > 0
      a = landmark.locations.to_a
      @post = a[rand(0..(a.size - 1))].post
      if not @post.likes
        @post.likes = 1
      else
        @post.likes += 1
      end
      Madmass.logger.debug "==[#{self}] Liked post #{@post.id} (currently #{@post.likes} likes)"
    elsif not landmark
      Madmass.logger.debug "==[#{self}] No landmark here (#{lat}, #{lon})"
    elsif landmark.locations.nil? or landmark.locations.empty?
      Madmass.logger.debug "==[#{self}] No post here (#{lat}, #{lon})"
    end
  end

  def build_result
    p = Madmass::Perception::Percept.new(self)
   
    if @post and @new_comment 
      p.data = {
        :post_id => @post.id,
        :comment => @new_comment.comment
      }
    end

    Madmass.current_perception << p
  end

end
