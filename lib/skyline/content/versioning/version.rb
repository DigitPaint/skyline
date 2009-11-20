class Skyline::Content::Versioning::Version < ActiveRecord::Base
  set_table_name "skyline_versions"
  belongs_to :versionable, :polymorphic => true
  alias_attribute :current_version, :version
  alias_attribute :current_author, :author
  
  class << self        
    # Increase the version number of the record
    # add the username as updater.
    # --
    def increase!(record,user)
      class_name = self.class_name(record)
      logger.warn("[VERSIONING] -- <#{class_name}: #{record.id}> [INCREASE]")
      if id = self.connection.select_value("SELECT id FROM #{self.table_name} WHERE versionable_type = '#{class_name}' AND versionable_id = #{record.id} LIMIT 1")
        self.connection.update "UPDATE #{self.table_name} SET version = version+1, author = '#{user.username.to_s}' WHERE id = #{id}"
      else
        self.connection.insert "INSERT INTO #{self.table_name} (versionable_type,versionable_id,version,author) VALUES ('#{class_name}',#{record.id},1,'#{user.username.to_s}')"
      end
    end
    
    # Remove the version as the original
    # record has also been removed.
    # --
    def destroy!(record)
      class_name = self.class_name(record)        
      logger.warn("[VERSIONING] -- <#{class_name}: #{record.id}> [DESTROY]")
      self.delete_all("versionable_type = '#{class_name}' AND versionable_id = #{record.id}")
    end
    
    protected
    
    def class_name(record)
      record.class.name
    end
  end
 
  # Version objects SHOULD NOT BE SAVED!
  def save(*params)
    return true
  end
  
end
