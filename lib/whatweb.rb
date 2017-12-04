# Copyright 2009 to 2017, Andrew Horton and Brendan Coles
#
# This file is part of WhatWeb.
#
# WhatWeb is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# at your option) any later version.
#
# WhatWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with WhatWeb.  If not, see <http://www.gnu.org/licenses/>.

# require 'profile' # debugging
require 'getoptlong'
require 'pp'
require 'net/http'
require 'open-uri'
require 'cgi'
require 'thread'
require 'rbconfig' # detect environment, e.g. windows or linux
require 'resolv'
require 'resolv-replace' # asynchronous DNS
require 'open-uri'
require 'digest/md5'

# WhatWeb libs
require 'lib/whatweb/version.rb'
require 'lib/whatweb/banner.rb'
require 'lib/whatweb/scan.rb'
require 'lib/whatweb/parser.rb'
require 'lib/gems.rb'
require 'lib/target.rb'
require 'lib/output_helper.rb'
require 'lib/plugins.rb'
require 'lib/plugin_support.rb'
require 'lib/logging.rb'
require 'lib/colour.rb'
require 'lib/version_class.rb'
require 'lib/http-status.rb'
require 'lib/extend-http.rb'

# load the lib/logging/ folder
Dir["#{File.expand_path(File.dirname(__FILE__))}/logging/*.rb"].each {|file| require file }

# Output options
$WWDEBUG = false # raise exceptions in plugins, etc
$verbose = 0 # $VERBOSE is reserved in ruby
$use_colour = 'auto'
$QUIET = false
$NO_ERRORS = false
$LOG_ERRORS = nil
$PLUGIN_TIMES = Hash.new(0)

# HTTP connection options
$USER_AGENT = "WhatWeb/#{WhatWeb::VERSION}"
$AGGRESSION = 1
$FOLLOW_REDIRECT = 'always'
$MAX_REDIRECTS = 10
$USE_PROXY = false
$PROXY_HOST = nil
$PROXY_PORT = 8080
$PROXY_USER = nil
$PROXY_PASS = nil
$HTTP_OPEN_TIMEOUT = 15
$HTTP_READ_TIMEOUT = 30
$WAIT = nil
$CUSTOM_HEADERS = {}
$BASIC_AUTH_USER = nil
$BASIC_AUTH_PASS = nil

# Ruby Version Compatability
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(2.0)
  raise('Unsupported version of Ruby. WhatWeb requires Ruby 2.0 or later.')
end

# Initialize HTTP Status class
HTTP_Status.initialize

# Look for directories 'plugins' and 'my-plugins'
# in the the WhatWeb root directory and ~/.whatweb directory
PLUGIN_DIRS = []
[ File.expand_path('..', __FILE__), "#{Dir.home}/.whatweb/" ].map do |dir|
  ['plugins', 'my-plugins'].each do |plugin_dir|
    PLUGIN_DIRS << plugin_dir if File.exist? plugin_dir
  end
end

