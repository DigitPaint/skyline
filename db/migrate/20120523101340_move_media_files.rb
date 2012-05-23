class MoveMediaFiles < ActiveRecord::Migration
  
  def up
    Skyline::MediaFile.all.each do |file|
      assets_path = Skyline::MediaNode.assets_path
    
      old_file_path = File.join(assets_path, file.id.to_s)
    
      if File.exist?(old_file_path)
        new_file_key = file.id.to_s.reverse.ljust(4, "0")
        new_file_path = File.join(assets_path, [new_file_key[0,2], new_file_key[2,2]].join('/'), file.id.to_s)
        
        FileUtils.makedirs(File.dirname(new_file_path))
        File.rename old_file_path, new_file_path
      end
    end
    
  end

  def down
    raise "cannot be undone"
  end
end
