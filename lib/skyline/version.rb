module Skyline
  # The defines the current Skyline version. 
  # Edge will always be the next TINY number.
  #
  # @private
  module VERSION
    MAJOR = 3
    MINOR = 0
    TINY = 7
 
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end