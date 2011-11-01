require 'rack/utils'

class Skyline::FlashSessionCookieMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      if @session_key.respond_to?(:call)
        sk = @session_key.call
      else
        sk = @session_key
      end      
      params = ::Rack::Utils.parse_query(env['QUERY_STRING'])
      env['HTTP_COOKIE'] = [ sk, params[sk] ].join('=').freeze unless params[sk].nil?
    end
    @app.call(env)
  end
end