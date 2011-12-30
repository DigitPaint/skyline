module Skyline
  # The defines the current Skyline version. 
  # 
  #
  # @private
  module VERSION
    MAJOR = 3
    MINOR = 2
    TINY = 0
    BUILD = 0

    # Some hackery to determine if we're on a development branch or not
    # this sets BUILD to a timestamp 
    begin
      git_dir = File.dirname(__FILE__) + "/../../.git"
      if File.exist?(git_dir)
        if `git --git-dir=#{git_dir} describe --tags HEAD` =~ /^v\d+\.\d+\.\d+(\.\d+)?$/
          build = nil
        else
          build = `git --git-dir=#{git_dir} show HEAD --format=format:"%h" 2>&1 -s`
          if build =~ /[0-9a-f]+/
            build = build.to_s
          else
            build = nil
          end
        end
      end
    rescue RuntimeError => e
    end
    
    # If no BUILD can be determined or we're on a version, it takes the last number
    build = build || BUILD
 
    STRING = [MAJOR, MINOR, TINY, build == 0 ? nil : build].compact.join('.')
  end
end