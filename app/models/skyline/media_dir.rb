class Skyline::MediaDir < Skyline::MediaNode
  extend ActiveSupport::Memoizable
  include UniqueIdentifiers
  
  has_many :files, :foreign_key => "parent_id", :class_name => "Skyline::MediaFile"
  has_many :nodes, :foreign_key => "parent_id", :class_name => "Skyline::MediaNode", :order => "type,name", :dependent => :destroy
  has_many :subdirectories, :foreign_key => "parent_id", :class_name => "Skyline::MediaDir"
            
  after_save :update_children_path
  
  unique_identifier :name, :scope => :parent_id, :default => "new_folder"
  
  validate :only_one_root
    
  class << self
    extend ActiveSupport::Memoizable
    # returns an Array of hashes
    #
    # ==== Returns
    # Array[Hash]:: Array of hashes grouped by parent_id
    def group_by_parent_id
      dirs = self.find(:all, :order => :name)
    
      out={}
      dirs.each do |o|
        out[o[:parent_id]] ||= []
        out[o[:parent_id]] << o
      end 
      out       
    end
    
    def root
      self.find_by_parent_id(nil)
    end
  end        
  
  def root?
    !self.parent_id
  end
   
  protected  
  def update_children_path
    if self.renamed?      
      sub_path = [(self.path && self.path.empty? ? nil : self.path),self.name.to_s].compact      
      Skyline::MediaFile.update_all("path = '#{sub_path}'","parent_id = #{self.id}")

      self.subdirectories.each do |dir|
        dir.path = File.join(sub_path)
      end
    end
  end
  def only_one_root
    if !self.parent_id
      if self.new_record?
        self.errors.add "cannot be another root node" if self.class.root
      else
        self.errors.add "cannot be another root node" if self.class.root && self.class.root.id != self.id
      end
    end
  end 
end
