if !Object.const_defined?(:Rails)
  require File.dirname(__FILE__) + "/../../../../config/environment"
end

def log(str)
  puts str if !Object.const_defined?(:SILENT_SEED) || SILENT_SEED == false
end

def stfu
  return yield if !Object.const_defined?(:SILENT_SEED) || SILENT_SEED == false
  
  begin
    orig_stderr = $stderr.clone
    orig_stdout = $stdout.clone
    $stderr.reopen File.new('/dev/null', 'w')
    $stdout.reopen File.new('/dev/null', 'w')
    retval = yield
  rescue Exception => e
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
    raise e
  ensure
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
  end
  retval
end

# ==================================
# = Definition of rights and roles =
# ==================================

log "== Clear current rightsets"

Skyline::Right.delete_all("1 = 1")
Skyline::Right.connection.execute("DELETE FROM skyline_rights_skyline_roles WHERE 1=1")

log "\n== Creating roles"

stfu do
  Skyline::Role.seed(:name,
    {:name => "super", :system => true},
    {:name => "editor", :system => false},
    {:name => "admin", :system => false}
  )
end

log "\n== Creating rights"

stfu do 
  Skyline::Right.seed(:name,
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
  )
end

log "\n== Mapping Rights to Roles"

super_role = Skyline::Role.find_by_name("super")
admin_role = Skyline::Role.find_by_name("admin")
editor_role = Skyline::Role.find_by_name("editor")
admin_rights = []
editor_rights = []

log " - Role : #{super_role.name}"
rights = Skyline::Right.all
rights.each do |r|
  log "    - #{r.name}"
  editor_rights << r if r.name.starts_with? 'article'
  admin_rights << r if r.name.starts_with? 'user'
end

super_role.rights = rights
super_role.save!
editor_role.rights = editor_rights
editor_role.save!
admin_role.rights = admin_rights
admin_role.save!
