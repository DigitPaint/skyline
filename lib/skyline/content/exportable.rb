module Skyline::Content
  # @private
  module Exportable
    
    # List of possible export formats for this class
    mattr_accessor :export_formats
    
    # Set a list of possible export format for this class
    # [DOC]
    def exportable_as(*formats)
      # discard any options for now
      options = formats.pop if formats.last.kind_of? Hash

      formats.each do |format|
        class << self; self; end.send(:define_method, "export_#{format}"){}
      end
      if formats.any?
        self.export_format = formats
        class << self; self; end.send(:define_method,:exportable?) do
          true
        end
      end
    end
    
  end # Exportable
end