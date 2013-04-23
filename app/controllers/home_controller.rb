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
    @locations = CloudTm::Location.all.to_dml_json
  end

  def map
    locations_in_cache = CloudTm::Location.all
    @locations = locations_in_cache.to_dml_json
    @edges = locations_in_cache.map(&:edges_for_percept).flatten.reject{|x| x == nil}.to_json #FIXME
  end

  def landmarks_map
    @landmarks = CloudTm::PostLandmark.all + CloudTm::VenueLandmark.all + CloudTm::TrackableLandmark.all
    locations = []
    edges = []
    @landmarks.each do |land| 
      land.locations.each do |geo| 
        #land.removeLocations(geo)
        locations << geo 
        
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
        track.locations.each do |location|
          if location.type == 'Track'
            locations << location 
          end
        end
      end
    end

    @locations = locations.to_dml_json
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
