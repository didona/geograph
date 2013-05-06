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

require 'haversine_distance.rb'

class Actions::GetNearbyPostsAction < Madmass::Action::Action
  action_params :latitude, :longitude, :user, :max_dist, :max_count

  def initialize params
    super
    @channels << :all
  end

  # the action effects.
  def execute
    Madmass.logger.debug "==[#{self}] ---"
    lat = BigDecimal.new(@parameters[:latitude])
    lon  = BigDecimal.new(@parameters[:longitude])
    max_dist = @parameters[:max_dist]
    max_count = @parameters[:max_count] ? @parameters[:max_count] : 10
    @nearby_posts = []
    landmark = CloudTm::PostLandmark.find_by_coordinates(lat, lon)
    Madmass.logger.debug "==[#{self}] Looking for posts near #{lat},#{lon} at distance #{max_dist}, maximum count #{max_count}"
    if landmark
      landmark.locations.each do |loc|
        adding = true
        if max_dist
          dist = HaversineDistance.calculate(lat, lon, loc.latitude, loc.longitude)
          if dist > max_dist
            adding = false 
          end
        end
        if adding
          @nearby_posts << loc.post
        end
        if max_count
          if @nearby_posts.size >= max_count
            break   # FIXME: maybe it has more sense to get the nearest max_count posts, not the first max_count posts
          end
        end
      end
    end
    Madmass.logger.debug "==[#{self}] Found #{@nearby_posts.size} posts"
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :nearby_posts => []
    }
    @nearby_posts.each do |pread|
      p.data[:nearby_posts] << {
        :id => pread.getExternalId,
        :latitude => pread.location.latitude.to_s,
        :longitude => pread.location.longitude.to_s
      }
    end

    Madmass.current_perception << p
  end

end
