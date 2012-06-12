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

# This service calculates all edges between geo objects and send them to the all channel.
class EdgesProcessor
  def initialize(options = {})
    @options = options
    Madmass.current_agent = Madmass::Agent::ProxyAgent.new(:status => 'init')
  end

  # Starts the production
  def run
    #Rails.logger.debug "Processing Edges"
    begin
      Madmass.current_agent.execute({:cmd => 'actions::process_edges'})
    rescue Exception => ex
      cause = main_cause ex
      unless cause.is_a?(Madmass::Errors::NotApplicableError)
        Madmass.logger.error("Raising a nasty error from the edge processor")
        raise cause
      end
    end
  end

  def main_cause exc
    main_causes_class = [Madmass::Errors::NotApplicableError]
    current = exc
    while current
    #  Madmass.logger.warn("Inspecting exception: #{current.class} --  #{current.message}")
      return current if main_causes_class.detect() { |c| c == current.class }
      current = current.class.method_defined?(:cause) ? current.cause : nil
    end
    return exc
  end

end
