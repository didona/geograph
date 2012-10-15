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

module CloudTm
  class GeoObject
    include CloudTm::Model

    def attributes_to_hash
      {
        :id => oid,
        :latitude => latitude.to_s,
        :longitude => longitude.to_s,
        :data => {:type => type, :body => body}
      }
    end

    def to_json
      attributes_to_hash.to_json
    end

    def destroy
      #FIXME manager.getRoot.removeGeoObjects(self)
    end


    #just for action strategy
    def compute_neighbours(strategy)
      distance = edge_max_dist(strategy)
      Rails.logger.debug "Request for computing neighbors with #{strategy} strategy and distance #{distance}"
      return if(distance < 0)
      Rails.logger.debug "Computing neighbors for #{strategy} strategy"
      CloudTm::GeoObject.all.each do |geo_obj|
        next if (self == geo_obj)
        if (HaversineDistance.calculate(self.latitude, self.longitude, geo_obj.latitude, geo_obj.longitude) <= distance)
          self.add_neighbours geo_obj
          geo_obj.add_neighbours self
        else
          self.remove_neighbours geo_obj
          geo_obj.remove_neighbours self
        end
      end
    end


    def edges_for_percept strategy = "any"
      return nil if(edge_max_dist(strategy)<0)
      edges = []
      get_neighbours.each do |geo_obj|
        edges << {:from => {
          :id => self.oid,
          :latitude => self.latitude.to_s,
          :longitude => self.longitude.to_s
        }, :to => {
          :id => geo_obj.oid,
          :latitude => geo_obj.latitude.to_s,
          :longitude => geo_obj.longitude.to_s
        }}
      end
      Madmass.logger.debug "New edges are #{edges.inspect}"
      edges
    end

    def edge_max_dist(strategy)
      properties = Properties.current
      return -1 unless properties and properties.edge_processor_strategy
      return -1 if (properties.edge_processor_strategy != strategy and strategy != "any")
      #FIXME should not consider Blogger and Reader Agent
      # return -1 if (self.type == BloggerAgent or self.type == ReaderAgent)
      properties.distance
    end

    class << self

      def find(oid)
        _oid = oid #Now ids are strings !! .to_i
        all.each do |geo_obj|
          return geo_obj if geo_obj.oid == _oid
        end
        return nil
      end

      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          # instance.set_root manager.getRoot
        end
      end


      alias_method_chain :create, :root

      #CHECKME


      def all
        geo_objects = []
        agents = FenixFramework.getDomainRoot().getApp.getAgents.to_a
        agents.each do |agent|
          geo_objects += agent.getPosts.to_a
        end
        geo_objects += agents
        Madmass.logger.debug "GeoObjects are #{geo_objects.to_yaml}"
        return geo_objects
      end

    end
  end
end