class Skyline::RouteConstraint
  class << self
    def matches?(request)
      is_skyline_path = false
      
      # Exclude /[skyline_prefix]/*
      is_skyline_path ||= (request.fullpath =~ /^\/?#{Regexp.escape(Skyline::Configuration.url_prefix)}/)
      
      # Also exclude /media/dirs
      is_skyline_path ||= (request.fullpath =~ /^\/?media\/dirs/)
      
      !is_skyline_path
    end
  end
end