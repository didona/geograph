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

class Actions::ReadPostAction < Madmass::Action::Action
  action_params :latitude, :longitude, :user

  def initialize params
    super
    @channels << :all
  end


  # the action effects.
  def execute

    lat = java.math.BigDecimal.new(@parameters[:latitude])
    lon  = java.math.BigDecimal.new(@parameters[:longitude])

    @posts_read = []

    dist = CloudTm::Properties.current ? CloudTm::Properties.current.distance : 850

    CloudTm::GeoObject.all.each do |post_obj|
      next if post_obj.type != "Post"
      if HaversineDistance.calculate(lat, lon, post_obj.latitude, post_obj.longitude) <= dist #FIXME @enabled_job.distance
        @posts_read << post_obj
        break #read just one post
      end
    end
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :posts_read => []
    }
    @posts_read.each do |pread|
      p.data[:posts_read] << {
        :id => pread.oid,
        :latitude => pread.latitude.to_s,
        :longitude => pread.longitude.to_s
      }
    end

    Madmass.current_perception << p
  end

end