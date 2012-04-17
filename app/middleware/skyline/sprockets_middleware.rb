require 'sprockets'
require 'pathname'

class Skyline::SprocketsMiddleware

  attr_accessor :environment

  def initialize(app,root,js_path,options={})
    @app = app
    @root = Pathname.new(root).realpath
    @options = options
    @environment = Sprockets::Environment.new((@root + js_path).to_s)
    @js_path = js_path
    @map = {}
    yield(self) if block_given?
  end
  
  def register_load_location(*paths)
    paths.each do |p|
      @environment.append_path(p)
    end
  end
  
  # Map an url to a real_file, both realtive to / or @root
  def map(url,real_file)
    @map[url] = real_file
  end
  
  def call(env)
    url = Rack::Utils.unescape(env["PATH_INFO"].to_s)
    
    url = url.sub(/^\//,"")
    
    if @map[url]
      path = Pathname.new(File.join(@root,@map[url]))
    elsif url.match(/^\/?#{Regexp.escape(@js_path)}\/(.*\/)?([\w\.]+\.js)$/)
      path = Pathname.new(File.join(@root,url))
      path = nil unless path.file?
    end
      
    if path && content = self.render(path)
      resp = ::Rack::Response.new do |res|
        res.status = 200
        res.headers["Content-Type"] = "text/javascript"
        res.write content
      end
      
      if @options[:cache]
        env["rack.errors"].puts "[Sprockets] Caching #{@root + url}"
        (@root + url).open("w") do |f|
          f.write content
        end
        # File.open(path ,"w")
      end
      
      resp.finish
    else
      return @app.call(env)
    end
  end
  
  def render(path)
    @environment.find_asset(path.to_s).to_s
  end
    
end