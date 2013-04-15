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
  class Post
    include CloudTm::Model

    def attributes_to_hash
      {
        :id => getExternalId,
        :latitude => latitude.to_s,
        :longitude => longitude.to_s,
        :likes => likes,
        :text => text,
        :data => {:type => type, :body => body}
      }
    end

    def destroy
    end

    class << self
      
      def all
        posts = []
        CloudTm::Landmark.all.each do |landmark|
          posts += landmark.getGeoObjects.to_a.select{|geo| geo.type == 'Post'}
        end
        Madmass.logger.debug "GeoObjects are #{posts.to_yaml}"
        return posts
      end

    end
  end
end