class AddMediaNodeDimensions < ActiveRecord::Migration
  def self.up
    add_column :skyline_media_nodes, :width, :integer
    add_column :skyline_media_nodes, :height, :integer
    Skyline::MediaFile.find_all_by_file_type("image").each do |mf|
      begin
        img = Magick::Image::read(mf.file_path).first
        mf.update_attributes({:width => img.columns, :height => img.rows});
      rescue
      end
    end
  end

  def self.down
    remove_column :skyline_media_nodes, :height
    remove_column :skyline_media_nodes, :width
  end
end
