class Skyline::Skyline2Controller < Skyline::ApplicationController
  layout "general"

  around_filter ::Sklyine::VersionStamper.instance  

  before_filter :load_implementation

    
  protected
  
  def load_implementation
    @implementation = Skyline::Content::Implementation.instance
  end
  
  # Returns the current implementation
  # --
  def current_implementation
    @implementation
  end

end