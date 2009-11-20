module Skyline::Content
  module Versioning
    module Versionable
      def self.included(obj)
        obj.send(:has_one, :skyline_version, :as => :versionable, :class_name => "Skyline::Content::Versioning::Version")
        obj.send(:delegate, :current_author, :to => :version)      
      end
      
      
      def version
        self.skyline_version || self.build_skyline_version(:version => 1, :author => "")
      end
      
      def current_version
        return @skyline_from_version if @skyline_keep_from_version && @skyline_from_version
        self.version.current_version
      end
      
      # The version this new data we want to save is built on.
      # --
      def from_version=(version)
        @skyline_from_version = version.to_i
      end
      
      def keep_version!
        @skyline_keep_from_version = true
      end
      
      
      # Does the version of the data to save match the one in the DB?
      # --
      def matching_versions?
        return true if @skyline_from_version.blank?
        self.version.current_version == @skyline_from_version
      end
    end
  end
end