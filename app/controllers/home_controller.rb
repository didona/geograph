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
    @edges = geo_objects_in_cache.map(&:edges_for_percept).flatten.to_json #FIXME
  end

  private

  def transact
    tx_monitor do
      yield
    end
  end

end
