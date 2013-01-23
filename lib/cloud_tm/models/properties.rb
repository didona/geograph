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
  class Properties
    include CloudTm::Model

    def destroy
      FenixFramework.getDomainRoot().getApp.removeProperties(self)
    end

    def has_properties?(options)
      options.each do |prop, value|
        return false if send(prop) != value
      end
      true
    end

    class << self

      def current
        FenixFramework.getDomainRoot.getApp.getProperties
      end

      def find_by_id(id)
        FenixFramework.getDomainObject(id)
      end

      def where(options = {})
        properties = []
        all.each do |property|
          properties << property if job.has_properties?(options)
        end
        return properties
      end

      def create_with_root attrs = {}, &block
        #Rails.logger.debug "root methods: #{manager.getRoot.methods.inspect}"
        create_without_root(attrs) do |instance|
          FenixFramework.getDomainRoot().getApp.properties = instance
        end
      end

      alias_method_chain :create, :root

      def all
        properties = FenixFramework.getDomainRoot.getApp.getProperties
        Rails.logger.debug "All properties are #{properties.inspect}"
        return [properties] if properties
        []
      end

    end
  end
end 