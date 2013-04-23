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

require 'java'


# Load the Cloud-TM Framework.
CLOUDTM_PATH = File.join(Rails.root, 'lib', 'cloud_tm') unless defined?(CLOUDTM_PATH)
CLOUDTM_JARS_PATH = File.join(CLOUDTM_PATH, 'jars') unless defined?(CLOUDTM_JARS_PATH)
CLOUDTM_MODELS_PATH = File.join(CLOUDTM_PATH, 'models') unless defined?(CLOUDTM_MODELS_PATH)
CLOUDTM_CONF_PATH = File.join(CLOUDTM_PATH, 'conf') unless defined?(CLOUDTM_CONF_PATH)

# Require all Cloud-TM and dependencies jars
Dir[File.join(CLOUDTM_JARS_PATH, '*.jar')].each { |jar|
  require jar
}
# Add jars path to the class path
$CLASSPATH << CLOUDTM_JARS_PATH
$CLASSPATH << CLOUDTM_CONF_PATH

module CloudTm

  FenixFramework = Java::PtIstFenixframework::FenixFramework

  class Framework
    class << self

      def init
        Madmass.transaction do
          Rails.logger.debug "[framework/init] getting domain root"
          root = FenixFramework.getDomainRoot()
          Rails.logger.debug "[framework/init] getting app"
          app = root.getApp()
          unless app
            Rails.logger.debug "[framework/init] app does not exist"
            app = CloudTm::Root.new
            root.setApp(app)
            Rails.logger.debug "[framework/init] ne app"
          end
          Rails.logger.debug "[framework/init] before commit"
        end
        Rails.logger.debug "[framework/init] after commit"
        # initialize the LocalityHints 
        CloudTm::HintsInitializer::init
      end

    end
  end
end

# TODO: make this step dynamic
# Load domain models
CloudTm::Location   = Java::ItAlgoGeographDomain::Location
CloudTm::Agent      = Java::ItAlgoGeographDomain::Agent
CloudTm::Trackable  = Java::ItAlgoGeographDomain::Trackable
CloudTm::Track      = Java::ItAlgoGeographDomain::Track
CloudTm::Post       = Java::ItAlgoGeographDomain::Post
CloudTm::PostLandmark      = Java::ItAlgoGeographDomain::PostLandmark
CloudTm::VenueLandmark     = Java::ItAlgoGeographDomain::VenueLandmark
CloudTm::TrackableLandmark = Java::ItAlgoGeographDomain::TrackableLandmark
CloudTm::Root       = Java::ItAlgoGeographDomain::Root
CloudTm::Comment    = Java::ItAlgoGeographDomain::Comment
CloudTm::Venue      = Java::ItAlgoGeographDomain::Venue

# Load DEF (Distributed Execution Framework)
CloudTm::DefaultExecutorService = Java::OrgInfinispanDistexec::DefaultExecutorService
CloudTm::DistributedTask        = Java::ItAlgoGeographTasks::DistributedTask
CloudTm::HintsInitializer       = Java::ItAlgoGeographTasks::HintsInitializer


Dir[File.join(CLOUDTM_PATH, '*.rb')].each { |ruby|
  next if ruby.match(/framework\.rb/)
  require ruby
}

Dir[File.join(CLOUDTM_MODELS_PATH, '*.rb')].each { |model|
  require model
}

