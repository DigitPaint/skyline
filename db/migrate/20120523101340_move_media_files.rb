class MoveMediaFiles < ActiveRecord::Migration
  
  def up
    assets_path = Skyline::MediaNode.assets_path
    
    Dir::Tmpname.create('migration', assets_path) do |tmpdir|
      Skyline::MediaFile.all.each do |file|
        old_file_path = File.join(assets_path, file.id.to_s)

        if File.exist?(old_file_path)
          new_file_key = file.id.to_s.reverse.ljust(4, "0")
          new_file_path = File.join(tmpdir, [new_file_key[0,2], new_file_key[2,2]].join('/'), file.id.to_s)
          FileUtils.makedirs(File.dirname(new_file_path))
          File.rename old_file_path, new_file_path
        end
      end
      
      leftovers = Dir.glob("#{assets_path}/*")
      leftovers.delete(tmpdir)
      
      if leftovers.any?
        puts "Found orphan files:"
        cleanup_path = File.join(assets_path, 'cleanup')
        FileUtils.makedirs(cleanup_path)
        leftovers.each do |leftover|
          if File.exists?(leftover)
            new_path = File.join(cleanup_path, File.basename(leftover))
            puts "#{new_path}"
            File.rename leftover, new_path
          end
        end
      end

      Skyline::MediaFile.all.each do |file|
        assets_path = Skyline::MediaNode.assets_path
        old_file_key = file.id.to_s.reverse.ljust(4, "0")
        old_file_path = File.join(tmpdir, [old_file_key[0,2], old_file_key[2,2]].join('/'), file.id.to_s)

        if File.exist?(old_file_path)
          new_file_key = file.id.to_s.reverse.ljust(4, "0")
          new_file_path = File.join(assets_path, [new_file_key[0,2], new_file_key[2,2]].join('/'), file.id.to_s)
          FileUtils.makedirs(File.dirname(new_file_path))
          File.rename old_file_path, new_file_path
        end
      end
      
      FileUtils.remove_entry_secure(tmpdir)
    end
    
  end

  def down
    raise "cannot be undone"
  end
end
