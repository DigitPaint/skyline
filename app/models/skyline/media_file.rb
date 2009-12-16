# @private
class Skyline::MediaFile < Skyline::MediaNode    
  has_and_belongs_to_many :tags, :class_name => "Skyline::Tag", :join_table => "skyline_media_files_skyline_tags"
	  
  include Skyline::Taggable

  after_create :store_data
  after_destroy :remove_data, :reset_ref_object
  validates_presence_of :data, :on => :create
  validates_uniqueness_of :name, :scope => "parent_id"
  
  default_scope :order => :name
    
  def self.set_missing_file_types
    self.all(:conditions => "file_type = '' OR file_type IS NULL").each do |media_file|
      media_file.set_file_type!
    end
    true
  end
  
  # returns thumbnail of image
  # ==== Parameters
  # width<Integer>:: required width of the thumbnail
  # height<Integer>:: required height of the thumbnail
  #
  # ==== Returns
  # <ImageBlob>:: blob of the Magick::Image  
  def thumbnail(width=100,height=100)
    img = Magick::Image::read(self.file_path).first
    
    org_w = img.columns
    org_h = img.rows
        
    if (width.to_i > org_w || height.to_i > org_h) 
      width = [width.to_i, org_w].min
      height = [height.to_i, org_h].min
    end

    stream = img.change_geometry!("#{width}x#{height}"){ |c,r,i| i.resize!(c,r) }
    stream.to_blob        
  end

  # returns the dimension of the original image
  #
  # ==== Returns
  # <Hash>:: hash of width and height attributes
  def dimension
    return nil if self.file_type != "image"
    {"width" => self.width, "height" => self.height}
  end
  
  # sanitize filename and set correct mime-type for IO object of file data
  #
  # ==== Parameters
  # data<IO>:: IO object with file data
  #
  # ==== Returns
  # data<IO>:: IO object with sanitized filename and correct mime-type
  def data=(data)
    unless data.size == 0
      @data = data
      self.name = sanitize_filename(@data.original_filename)
      
      # Fix the mime types
      @data.content_type = MIME::Types.type_for(@data.original_filename).to_s
      self.content_type = @data.content_type.downcase.gsub(/[^a-z\-\/]/,"")
      self.file_type = self.determine_file_type
      
      self.set_dimensions
      self.size = @data.size
    end
    @data
  end

  def data
    @data
  end

  def url(prefix=nil)
    if prefix
      "/media_dirs/#{self.parent_id}/media_files_data/#{prefix}/#{self.name}"
    else
      "/media_dirs/#{self.parent_id}/media_files_data/#{self.name}"
    end
  end
  
  def determine_file_type
    lookup = Mime::Type.lookup(self.content_type)
    lookup.instance_variable_get("@symbol").to_s
  end
  
  def set_file_type!
    file_type = determine_file_type
    self.update_attribute(:file_type, file_type) unless file_type.blank?
  end
      
  protected
  
  def set_dimensions
    return if self.file_type != "image"
    
    begin
      img = case self.data
      when ActionController::UploadedTempfile,Tempfile
        Magick::Image::read(self.data.path).first
      else
        Magick::Image::from_blob(self.data.read).first
        self.data.rewind        
      end
      
      self.width = img.columns
      self.height = img.rows
    rescue
    end
  end
  
  
  # Write data to disk
  def store_data
    File.open(self.file_path,"wb"){ |f| f.write(self.data.read) } if self.data
  end
  
  # Remove data from disk
  def remove_data
    File.unlink(self.file_path) if File.exist?(self.file_path)
  end 
  
  # reset ref objects that refer to removed media file
  # by setting referable_id = nil
  def reset_ref_object
    Skyline::RefObject.update_all({:referable_id => nil}, {:referable_id => self.id, :referable_type => self.class.name})    
  end
end
