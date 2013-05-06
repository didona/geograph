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


class Actions::CommentPostAction < Madmass::Action::Action
  action_params :post_id, :latitude, :longitude, :user

  def initialize params
    super
  end

  def execute
    Madmass.logger.debug "==[#{self}] ---"
    lat = BigDecimal.new(@parameters[:latitude])
    lon  = BigDecimal.new(@parameters[:longitude])
    Madmass.logger.debug "==[#{self}] looking for landmark near #{lat},#{long}"
    landmark = CloudTm::PostLandmark.find_by_coordinates(lat, lon)
    if landmark and landmark.locations and landmark.locations.size > 0
      Madmass.logger.debug "==[#{self}] landmark #{landmark}"
      locs = landmark.locations.to_a
      @post = nil
      locs.each do |loc|
        Madmass.logger.debug "==[#{self}] loc #{loc} ; #{loc.inspect}"
        if loc.post.id == @parameters[:post_id]
          @post = loc.post
          break
        end
      end
      ## HERE FIXME post is nil!!
#      @new_comment = CloudTm::Comment.create(
#        :comment => "This is comment #{@post.comments.size + 1} to post #{@post.id} '#{@post.text ? @post.text[0..10] : ''}'"
#      )
#      @post.addComments @new_comment
#      Madmass.logger.debug "==[#{self}] Commented post #{@post.id} with '#{@new_comment.comment}'"
      Madmass.logger.debug "==[#{self}] is there any post? #{@post}"
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
