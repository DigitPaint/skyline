if !Object.const_defined?(:Rails)
  require File.dirname(__FILE__) + "/../../../../../config/environment"
end

def log(str)
  puts str if !Object.const_defined?(:SILENT_SEED) || SILENT_SEED == false
end

# ==================================
# = Definition of rights and roles =
# ==================================

log "== Clear current rightsets"

Skyline::Right.delete_all("1 = 1")
Skyline::Right.connection.execute("DELETE FROM skyline_rights_skyline_roles WHERE 1=1")

log "\n== Creating roles"

Skyline::Role.seed_many(:name,[
  {:name => "super", :system => true}
])

log "\n== Creating rights"
Skyline::Right.seed_many(:name,[
  {:name => "media_dir_create"},
  {:name => "media_dir_update"},
  {:name => "media_dir_delete"},
  {:name => "media_file_create"},
  {:name => "media_file_update"},
  {:name => "media_file_delete"},
  {:name => "media_file_show"},
  
  {:name => "page_index"},
  {:name => "page_create"},
  {:name => "page_show"},
  {:name => "page_update"},
  {:name => "page_lock"},
  {:name => "page_variant_create"},
  {:name => "page_variant_delete"},

  {:name => "page_fragment_index"},
  {:name => "page_fragment_create"},
  {:name => "page_fragment_show"},
  {:name => "page_fragment_update"},
  {:name => "page_fragment_lock"},
  {:name => "page_fragment_variant_create"},
  {:name => "page_fragment_variant_delete"},


  {:name => "article_index"},
  {:name => "article_create"},
  {:name => "article_show"},
  {:name => "article_update"},
  {:name => "article_lock"},
  {:name => "article_variant_create"},
  {:name => "article_variant_delete"},

  
  {:name => "variant_force_edit"},  # If a user has the "force_edit" right he can force to edit a certain page, even if someone else is editing it.
  
  {:name => "settings_update"},
  
  {:name => "user_create"},
  {:name => "user_update"},
  {:name => "user_show"},
  {:name => "user_delete"},
  
  {:name => "tinymce_edit_html"} # Defines wether or not to show the "edit html" button in the toolbar
])

log "\n== Mapping Rights to Roles"

role = Skyline::Role.find_by_name("super")
log " - Role : #{role.name}"
rights = Skyline::Right.all
rights.each do |r|
  log "    - #{r.name}"
end  
role.rights = rights
role.save!
