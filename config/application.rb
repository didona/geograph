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

require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Geograph
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += Dir["#{config.root}/lib", "#{config.root}/lib/**/"]
    # config.autoload_paths += %W(#{config.root}/extras)

    config.after_initialize do
      begin
        #FIXME: Move somewhere else and invoke here!
        require File.join(Rails.root, 'lib', 'cloud_tm', 'framework')
        #Configure jgroups to use the gossip router
        #Note: The gossip router is in the users db
        #Note2: This must be done after Geograph initializers
        jgroups_conf_dir = File.join(Rails.root, "lib", "fenix", "conf")
        # open the template file, replace the GOSSIP_ROUTER_PLACEHOLDER right value
        jgossip_address = "#{Madmass.install_options(:cluster_nodes)[:db_nodes].first}[12001]"
        File.open(File.join(jgroups_conf_dir, "jgroups.xml.template"), 'r') do |template|
          jgroups_conf = template.read.gsub("{GOSSIP_ROUTER_PLACEHOLDER}", jgossip_address)
          File.open(File.join(jgroups_conf_dir, "jgroups.xml"), 'w') do |original|
            original.write jgroups_conf
          end
        end

        # loading the Fenix Framework
        CloudTm::Framework.init(
          :dml => 'geograph.dml',
          :conf => 'infinispan-conf.xml',
          :framework => CloudTm::Config::Framework::ISPN
        )
      rescue Exception => ex
        Rails.logger.error "Cannot load Cloud-TM Framework: #{ex}"
      end
    end
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
