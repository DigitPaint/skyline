module Skyline::Rendering::Helpers::SettingsHelper
  # A safe way to get a value of a setting and report a warning if it can't be found  
  # instead of calling Setting[:setting_identifier].field directly use setting(:setting_identifier, :field)
  # 
  # @param setting_identifier [Symbol] the symbol of the settings page
  # @param field [Symbol] the name of the setting
  # 
  # @return Object the value of the setting or nil if not found
  def setting(setting_identifier, field)
    if s = ::Settings[setting_identifier] 
      if s.respond_to?(field)
        return s.send(field)
      end
    end
    Rails.logger.warn "Couldn't find Setting[:#{setting_identifier}].#{field}"
    nil
  end
  
  # a safe way to get a page from the settings  
  # 
  # @param setting_identifier [Symbol] the symbol of the settings page
  # @param field [Symbol] the name of the setting that references a page_id
  # 
  # @return [Page,nil] The page if found, nil otherwise
  def page_from_setting(setting_identifier, field)
    if page_id = setting(setting_identifier, field)
      return Skyline::Page.find_by_id(page_id) if page_id.present?
    end    
    nil
  end  
end