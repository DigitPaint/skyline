module Skyline::Browser::Tabs::MediaLibrary::MediaFilesHelper
  def skyline_browser_tabs_media_library_media_dir_media_files_path_with_session_information(media_dir)
    session_key = ActionController::Base.session_options[:session_key]
    skyline_browser_tabs_media_library_media_dir_media_files_path(media_dir, session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
  end
end