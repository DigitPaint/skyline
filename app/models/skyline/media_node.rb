# @private
class Skyline::MediaNode < ActiveRecord::Base
  self.table_name = "skyline_media_nodes"

  belongs_to :directory, :foreign_key => "parent_id", :class_name => "Skyline::MediaDir"
  
  cattr_accessor :assets_path
  @@assets_path ||= Skyline::Configuration.assets_path

  before_create :set_path  
  
  class << self
    # sanitize nodename
    # ==== Parameters
    # filename<String>:: nodename that has to be sanitized
    #
    # ==== Returns
    # <String>:: sanitized nodename
    def sanitize_filename(filename)
      filename = filename.gsub("\\","/")
      filename = filename.downcase.gsub(/[^a-z0-9\.\-\+_]/,"_").squeeze("_")
      filename = "_#{filename}" if filename =~ /^\.+$/
      filename
    end
     
  end
  
  # check if filename has been sanitized
  # ==== Returns
  # <Boolean>:: true if sanitized
  def sanitized?
    @sanitized
  end

  # return the sanitized nodename as name
  #
  # ==== Parameters
  # name<String>:: original nodename
  #
  # ==== Returns
  # <String>:: satized name
  def name=(name)
    name = sanitize_filename(name)
    @renamed = true if name != self.name
    write_attribute(:name, name)
  end

  # write the path of the node
  #
  # ==== Parameters
  # name<String>:: original nodename
  def path=(name)
    @renamed = true if name != self.name
    write_attribute(:path, name)
  end  
  
  # check if node has been renamed after sanitizing the name
  # ==== Returns
  # <Boolean>:: true if renamed
  # sets @renamed if file was sanitized  
  def renamed?
    @renamed
  end
  
  # returns the full path of the media node
  # ==== Retruns
  # <String>:: Full path including parent and filename
  def full_path
    p = File.join(self.path.to_s,self.name) 
    p = p[1,p.size] if p[0,1] == "/"
    p
  end
  
  # returns the path of the media node
  # ==== Retruns
  # <String>:: path 
  def file_path
    file_key = self.id.to_s.reverse.ljust(4, "0")
    File.join(self.class.assets_path, [file_key[0,2],file_key[2,2]].join('/'), self.id.to_s)
  end  

  def title
    self[:title].present? ? self[:title] : self.name
  end

  protected
  # set the path of a directory node extracted from directory.full_path   
  def set_path
    return unless self.directory
    self.path = self.directory.full_path
  end
  
  # sanitize nodename
  # ==== Parameters
  # filename<String>:: nodename that has to be sanitized
  #
  # ==== Returns
  # <String>:: sanitized nodename
  # sets @sanitized if file was sanitized
  def sanitize_filename(filename)    
    orig = filename.dup
    filename = self.class.sanitize_filename(filename)      
    @sanitized = true if filename != orig
    filename    
  end  
end
