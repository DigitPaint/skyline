# This middleware will clean out the session for all lower and will put the old values back 
# on the way back.
#
# This is needed to have separate session management for Skyline.
#
class Skyline::SessionScrubberMiddleware
    
  def initialize(app)
    @app = app
  end
    
  def call(env)
    store_keys = %w{rack.session rack.session.options rack.session.record rack.session.unpacked_cookie_data action_dispatch.request.unsigned_session_cookie}
    # Store & remove these keys from ENV
    store = store_keys.inject({}){|mem, v| mem[v] = env[v]; env[v] = nil; mem}
    @app.call(env)
  ensure
    store.each do |k,v| 
      env[k] = v
    end
  end
    
end
