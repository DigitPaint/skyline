# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# inspired by http://filext.com/file-extension/BMP

mime_types = {
  :image =>      %w{image/jpeg
                    image/jpg
                    image/jp_
                    application/jpg
                    application/x-jpg
                    image/pjpeg
                    image/pipeg
                    image/vnd.swiftview-jpeg
                    image/x-xbitmap
                    image/png
                    image/x-png
                    application/png
                    application/x-png
                    image/gif
                    image/x-xbitmap
                    image/gi_
                    image/bmp
                    image/x-bmp
                    image/x-bitmap
                    image/x-xbitmap
                    image/x-win-bitmap
                    image/x-windows-bmp
                    image/ms-bmp
                    image/x-ms-bmp
                    application/bmp
                    application/x-bmp
                    application/x-win-bitmap
                    application/preview
                    image/tiff
                    image/tif
                    image/x-tif
                    image/tiff
                    image/x-tiff
                    application/tif
                    application/x-tif
                    application/tiff
                    application/x-tiff
                    image/photoshop
                    image/x-photoshop
                    image/psd
                    application/photoshop
                    application/psd
                    zz-application/zz-winassoc-psd},
  :video =>      %w{video/x-flv
                    video/quicktime
                    video/x-quicktime
                    image/mov
                    audio/aiff
                    audio/x-midi
                    audio/x-wav
                    video/avi
                    video/avi
                    video/msvideo
                    video/x-msvideo
                    image/avi
                    video/xmpg2
                    application/x-troff-msvideo
                    audio/aiff
                    audio/avi                    
                    video/mpeg
                    video/mpg
                    video/x-mpg
                    video/mpeg2
                    application/x-pn-mpg
                    video/x-mpeg
                    video/x-mpeg2a
                    audio/mpeg
                    audio/x-mpeg
                    image/mpg
                    video/mp4v-es
                    audio/mp4
                    video/ogg},
  :audio =>      %w{audio/mpeg
                    audio/x-mpeg
                    audio/mp3
                    audio/x-mp3
                    audio/mpeg3
                    audio/x-mpeg3
                    audio/mpg
                    audio/x-mpg
                    audio/x-mpegaudio
                    audio/ogg
                    application/ogg
                    audio/x-ogg
                    application/x-ogg
                    audio/flac
                    audio/wav
                    audio/x-wav
                    audio/wave
                    audio/x-pn-wav
                    audio/mid
                    audio/m
                    audio/midi
                    audio/x-midi
                    application/x-midi
                    audio/ac3},
  :excel =>      %w{application/vnd.ms-excel
                    application/msexcel
                    application/x-msexcel
                    application/x-ms-excel
                    application/vnd.ms-excel
                    application/x-excel
                    application/x-dos_ms_excel
                    application/xls
                    application/x-xls
                    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                    application/vndopenxmlformats-officedocumentspreadsheetmlsheet
                    application/vndms-excelapplication/excel},
  :word =>       %w{application/msword
                    application/doc
                    appl/text
                    application/vnd.msword
                    application/vnd.ms-word
                    application/winword
                    application/word
                    application/x-msw6
                    application/x-msword
                    application/vnd.openxmlformats-officedocument.wordprocessingml.document
                    application/mswordapplication/x-mswordapplication/x-wordapplication/wordtext/plain
                    application/rtf
                    application/x-rtf
                    text/rtf
                    text/richtext
                    application/msword
                    application/doc
                    application/x-soffice
                    application/vndopenxmlformats-officedocumentwordprocessingmldocument},
  :powerpoint => %w{application/vnd.ms-powerpoint
                    application/mspowerpoint
                    application/ms-powerpoint
                    application/mspowerpnt
                    application/vnd-mspowerpoint
                    application/powerpoint
                    application/x-powerpoint
                    application/x-mspowerpoint
                    application/vnd.openxmlformats-officedocument.presentationml.presentation
                    application/vndms-powerpointapplication/powerpoint
                    application/vndopenxmlformats-officedocumentpresentationmlpresentation},
  :flash =>      %w{application/x-shockwave-flash
                    application/x-shockwave-flash2-preview
                    application/futuresplash
                    image/vnd.rn-realflash},
#  :text =>       %w{text/plain
#                    application/txt
#                    browser/internal
#                    text/anytext
#                    widetext/plain
#                    widetext/paragraph},
  :executable => %w{application/octet-stream
                    application/x-msdownload
                    application/exe
                    application/x-exe
                    application/dos-exe
                    vms/exe
                    application/x-winexe
                    application/msdos-windows
                    application/x-msdos-program},
  :compressed => %w{application/x-7z-compressed
                    application/gzip
                    application/x-gzip
                    application/x-gunzip
                    application/gzipped
                    application/gzip-compressed
                    application/x-compressed
                    application/x-compress
                    gzip/document
                    application/octet-stream  
                    application/arj
                    application/x-arj
                    application/x-compress
                    application/x-compressed
                    application/x-winzip
                    application/x-tar
                    application/x-gzip
                    application/x-stuffit
                    zz-application/zz-winassoc-arj
                    application/x-rar-compressed
                    application/rar
                    application/x-compressed
                    application/x-rar
                    application/x-rar-compressed
                    compressed/rar
                    application/zip
                    application/x-zip
                    application/x-zip-compressed
                    application/octet-stream
                    application/x-compress
                    application/x-compressed
                    multipart/x-zip
                    application/gzip
                    application/x-gzip
                    application/x-gunzip
                    application/gzipped
                    application/gzip-compressed
                    application/x-compressed
                    application/x-compress
                    gzip/document
                    application/octet-stream
                    application/tar
                    application/x-tar
                    applicaton/x-gtar
                    multipart/x-tar
                    application/x-compress
                    application/x-compressed
                    application/x-bzip}    
}

mime_types.each do |symbol, types|
  Mime::Type.register types.first, symbol, types.uniq
end