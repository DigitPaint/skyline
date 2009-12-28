class CreateSkylineReferableUris < ActiveRecord::Migration
  class Skyline::LinkSectionLink < ActiveRecord::Base
    set_table_name "skyline_link_section_links"     
    include Skyline::BelongsToReferable
    belongs_to_referable :linked    
  end
  
  class Skyline::Sections::MediaSection < ActiveRecord::Base
    set_table_name "skyline_sections_media_sections"     
    include Skyline::BelongsToReferable
    belongs_to_referable :linked
  end
  
  class Skyline::Sections::RedirectSection < ActiveRecord::Base
    set_table_name "skyline_sections_redirect_sections"     
    include Skyline::BelongsToReferable
    belongs_to_referable :linked
  end  
  
  class Skyline::ReferableUri < ActiveRecord::Base
    set_table_name :skyline_referable_uris    
  end
    
  def self.up
    create_table :skyline_referable_uris do |t|
      t.string :uri
      t.timestamps
    end
    
    # LinkSectionLink
    items = Skyline::LinkSectionLink.all(:conditions => "(linked_id = '' OR linked_id IS NULL) AND (custom_url != '' AND custom_url IS NOT NULL)")
    items.each do |i|
      uri = Skyline::ReferableUri.create(:uri => i.custom_url)
      i.build_linked(:referable => uri)
      i.save
    end
    remove_column :skyline_link_section_links, :custom_url
    
    # Sections::MediaSection
    items = Skyline::Sections::MediaSection.all(:conditions => "(linked_id = '' OR linked_id IS NULL) AND (custom_url != '' AND custom_url IS NOT NULL)")
    items.each do |i|
      uri = Skyline::ReferableUri.create(:uri => i.custom_url)
      i.build_linked(:referable => uri)
      i.save
    end
    remove_column :skyline_sections_media_sections, :custom_url
    
    # Sections::RedirectSection
    items = Skyline::Sections::RedirectSection.all(:conditions => "(linked_id = '' OR linked_id IS NULL) AND (custom_url != '' AND custom_url IS NOT NULL)")
    items.each do |i|
      uri = Skyline::ReferableUri.create(:uri => i.custom_url)
      i.build_linked(:referable => uri)
      i.save
    end
    remove_column :skyline_sections_redirect_sections, :custom_url
     
  end

  def self.down
    raise "cannot be undone"
  end
end
