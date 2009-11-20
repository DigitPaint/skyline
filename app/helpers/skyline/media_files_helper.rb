module Skyline::MediaFilesHelper
  def skyline_media_file_path_with_session_information(media_dir)
    session_key = ActionController::Base.session_options[:session_key] || ActionController::Base.session_options[:key]
    skyline_media_dir_media_files_path(media_dir, session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
  end
end