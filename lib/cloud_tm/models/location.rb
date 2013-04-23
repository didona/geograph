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
  class Location
    include CloudTm::Model

    def attributes_to_hash
      {
        :id => getExternalId,
        :latitude => latitude.to_s,
        :longitude => longitude.to_s,
        :data => {:type => type, :body => body}
      }
    end

    def destroy
    end

    class << self
      
      #def factory attrs = {}
      #  if(attrs[:locality_key] and attrs[:locality_value])
      #    instance = new new_locality_hint(attrs.delete(:locality_key), attrs.delete(:locality_value))
      #  else
      #    instance = new
      #  end
      #  instance.latitude = attrs[:latitude]
      #  instance.longitude = attrs[:longitude]
      #  instance.body = attrs[:body]
      #  instance.type = attrs[:type]
      #  instance
      #end

      def all
        locations = []
        CloudTm::PostLandmark.all.each do |landmark|
          locations += landmark.getLocations.to_a
        end
        CloudTm::VenueLandmark.all.each do |landmark|
          locations += landmark.getLocations.to_a
        end
        CloudTm::TrackableLandmark.all.each do |landmark|
          locations += landmark.getLocations.to_a
        end
        Madmass.logger.debug "Locations are #{locations.to_yaml}"
        return locations
      end

    end
  end
end
