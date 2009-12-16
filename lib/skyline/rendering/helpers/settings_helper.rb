module Skyline::Rendering::Helpers::SettingsHelper
  # A safe way to get a value of a setting and report a warning if it can't be found  
  # instead of calling Setting[:setting_identifier].field directly use setting(:setting_identifier, :field)
  # 
  # @param setting_identifier [Symbol] the symbol of the settings page
  # @param field [Symbol] the name of the setting
  # 
  # @return [Object] the value of the setting or nil if not found
  # 
  # @deprecated Will be removed 3.1 in favour of {Skyline::Settings::KlassMethods#get}
  def setting(setting_identifier, field)
    ::Settings.get(setting_identifier,field)
  end
  
  # a safe way to get a page from the settings  
  # 
  # @param setting_identifier [Symbol] the symbol of the settings page
  # @param field [Symbol] the name of the setting that references a page_id
  # 
  # @return [Page, NilClass] The page if found, nil otherwise
  # 
  # @deprecated Will be removed 3.1 in favour of {Skyline::Settings::KlassMethods#get_page}  
  def page_from_setting(setting_identifier, field)
    ::Settings.get_page(setting_identifier,field)
  end
end