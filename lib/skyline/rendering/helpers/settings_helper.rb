module Skyline::Rendering::Helpers::SettingsHelper
  # a safe way to get a value of a setting and report a warning if it can't be found  
  # instead of calling Setting[:setting_identifier].field directly use setting(:setting_identifier, :field)
  # ==== Parameters
  # setting_identifier<Symbol>:: the symbol of the settings page
  # field<Symbol>:: the name of the setting
  # 
  # ==== Returns
  # Object:: the value of the setting or nil if not found
  # --
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
  # ==== Parameters
  # setting_identifier<Symbol>:: the symbol of the settings page
  # field<Symbol>:: the name of the setting that references a page_id
  # 
  # ==== Returns
  # Page:: the page if found or nil otherwise
  # --
  def page_from_setting(setting_identifier, field)
    if page_id = setting(setting_identifier, field)
      return Skyline::Page.find_by_id(page_id) if page_id.present?
    end    
    nil
  end  
end