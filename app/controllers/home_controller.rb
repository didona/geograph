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

class HomeController < ApplicationController
  before_filter :authenticate_agent
  include Madmass::Transaction::TxMonitor
  around_filter :transact
  respond_to :html, :js
  
  def index
    @geo_objects = CloudTm::GeoObject.all.to_dml_json
  end

  def map
    geo_objects_in_cache = CloudTm::GeoObject.all
    @geo_objects = geo_objects_in_cache.to_dml_json
    @edges = geo_objects_in_cache.map(&:edges_for_percept).flatten.reject{|x| x == nil}.to_json #FIXME
  end

  def landmarks_map
    @landmarks = CloudTm::Landmark.all
    geo_objects = []
    edges = []
    @landmarks.each do |land| 
      land.geoObjects.each do |geo| 
        #land.removeGeoObjects(geo)
        geo_objects << geo 
        
        edges << {
          :from => {
            :id => land.externalId,
            :latitude => land.latitude.to_s,
            :longitude => land.longitude.to_s
          }, 
          :to => {
            :id => geo.externalId,
            :latitude => geo.latitude.to_s,
            :longitude => geo.longitude.to_s
          }
        }
      end
    end
    # get all agents tracks
    agents = CloudTm::Trackable.all
    agents.each do |agent|
      next if(agent.class != CloudTm::Trackable)
      agent.tracks.each do |track|
        track.geo_objects.each do |geo_object|
          if geo_object.type == 'Track'
            geo_objects << geo_object 
          end
        end
      end
    end

    @geo_objects = geo_objects.to_dml_json
    @landmarks_objects = @landmarks.to_dml_json
    @edges = edges.to_json
  end

  private

  def transact
    tx_monitor do
      yield
    end
  end

end
