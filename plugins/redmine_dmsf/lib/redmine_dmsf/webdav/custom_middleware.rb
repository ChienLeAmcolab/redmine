# frozen_string_literal: true

# Redmine plugin for Document Management System "Features"
#
# Karel Pičman <karel.picman@kontron.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require "#{File.dirname(__FILE__)}/../../dav4rack"
require "#{File.dirname(__FILE__)}/resource_proxy"

module RedmineDmsf
  module Webdav
    AUTHENTICATION_REALM = 'DMSF content'
    # Custom middleware
    class CustomMiddleware
      def initialize(app)
        @rails_app = app
        path = '/dmsf/webdav'
        @dav_app = Rack::Builder.new do
          map path do
            run Dav4rack::Handler.new(
              root_uri_path: path,
              resource_class: RedmineDmsf::Webdav::ResourceProxy,
              allow_unauthenticated_options_on_root: true,
              controller_class: DmsfController
            )
          end
        end
        # .to_app
      end

      def call(env)
        begin
          status, headers, body = @dav_app.call env
        rescue StandardError => e
          Rails.logger.error e.message
          status = e
          headers = {}
          body = ['']
        end
        # If the URL map generated by Rack::Builder did not find a matching path,
        # it will return a 404 along with the x-cascade header set to 'pass'.
        if (status == 404) && (headers['x-cascade'] == 'pass')
          @rails_app.call env # let Rails handle the request
        else
          [status, headers, body]
        end
      end
    end
  end
end
