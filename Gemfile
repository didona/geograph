source 'http://rubygems.org'

gem 'rails', '>= 3.2.12'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'jruby-openssl'
gem 'json'

# Gems used only for assets and not required
# in production environments by default.
group :assets do 
  gem 'sass' #,   '3.1.4'
  gem 'sass-rails'#,   '3.1.4'
  gem 'coffee-rails'#, '~> 3.1.1'
  gem 'uglifier'#, '>= 1.0.3'
end

group :development, :test do
   gem 'torquebox-server'
end

# Jruby + Torquebox specific gems
group :torquebox, :production do
  gem 'jruby-openssl', :platform => :jruby
#  gem 'newrelic_rpm'
  gem 'json-jruby'
end

gem 'jquery-rails', '2.0.2'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

gem "jruby-openssl"
gem "socky-client", "0.4.3"
gem "socky-client-rails", "0.4.5"
#gem "socky-server", "0.4.1"

gem "jdbc-mysql"
gem 'activerecord-jdbcmysql-adapter'
gem "activerecord-jdbc-adapter"

gem 'execjs'
gem 'therubyrhino'

gem "devise", '< 2.0.0'

gem "madmass",  :git => "git://github.com/algorithmica/madmass.git"
#gem "madmass", :path => "../madmass"

#gem 'rcov', '0.9.11'
#gem 'bundler','1.0.21'
