class Skyline::FileCacheSweeper < ActiveRecord::Observer
  observe Skyline::MediaFile, Skyline::MediaDir, Skyline::MediaNode
  
  def after_save(record)
    if record.renamed?
    expire_for(record)
    end 
  end
  
  def after_destroy(record)
    expire_for(record)    
  end

  def expire_for(record)    
    case record
      when Skyline::MediaFile
        Skyline::MediaCache.destroy_all("object_id = #{record.id} AND object_type = 'MediaFile'")
      when Skyline::MediaDir
        ids = record.files.collect{|f| f.id}.join(",")
        Skyline::MediaCache.destroy_all("object_id IN (#{ids}) AND object_type = 'MediaFile'") unless ids.blank?
    end
  end
end
